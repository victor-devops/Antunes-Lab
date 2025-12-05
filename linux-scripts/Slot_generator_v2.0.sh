#!/usr/bin/env bash
set -euo pipefail

echo "                                                                    ";
echo "                                                                    ";
echo " █████   █████            █████████           █████   █████         ";
echo "▒▒███   ▒▒███            ███▒▒▒▒▒███         ▒▒███   ▒▒███          ";
echo " ▒███    ▒███   ██████  ███     ▒▒▒   ██████  ▒███    ▒███   ██████ ";
echo " ▒███    ▒███  ███▒▒███▒███          ███▒▒███ ▒███    ▒███  ███▒▒███";
echo " ▒▒███   ███  ▒███ ▒███▒███         ▒███ ▒███ ▒▒███   ███  ▒███ ▒███";
echo "  ▒▒▒█████▒   ▒███ ▒███▒▒███     ███▒███ ▒███  ▒▒▒█████▒   ▒███ ▒███";
echo "    ▒▒███     ▒▒██████  ▒▒█████████ ▒▒██████     ▒▒███     ▒▒██████ ";
echo "     ▒▒▒       ▒▒▒▒▒▒    ▒▒▒▒▒▒▒▒▒   ▒▒▒▒▒▒       ▒▒▒       ▒▒▒▒▒▒  ";
echo "                                                                    ";
echo "                                                                    ";
echo "    ================== Device Slot Generator ==================     ";
echo "                                                                    ";

# Colours
GREEN="\033[0;32m"
NC="\033[0m"  # reset

read -rp "Enter the path to base config file: " CFG_FILE
if [[ ! -f "$CFG_FILE" ]]; then
  echo "ERROR: File not found: $CFG_FILE" >&2
  exit 1
fi

read -rp "Enter customer name: " CUSTOMER

read -rp "Number of new headsets (VocoVoice) to add: " QTY_HEADSET
QTY_HEADSET=${QTY_HEADSET:-0}

read -rp "Number of new handsets (VocoPhone) to add: " QTY_HANDSET
QTY_HANDSET=${QTY_HANDSET:-0}

read -rp "Number of new keypads (VocoMessage) to add: " QTY_KEYPAD
QTY_KEYPAD=${QTY_KEYPAD:-0}

read -rp "Number of new call points (VocoTouch) to add: " QTY_CALLPOINT
QTY_CALLPOINT=${QTY_CALLPOINT:-0}

# Sanity checks on quantities
for q in QTY_HEADSET QTY_HANDSET QTY_KEYPAD QTY_CALLPOINT; do
  v=${!q}
  if ! [[ "$v" =~ ^[0-9]+$ ]]; then
    echo "Error: $q must be an integer (got '$v')." >&2
    exit 1
  fi
done

TOTAL=$((QTY_HEADSET + QTY_HANDSET + QTY_KEYPAD + QTY_CALLPOINT))
if (( TOTAL <= 0 )); then
  echo "Nothing to generate (all quantities are 0)." >&2
  exit 0
fi

trim() {
  local s="$1"
  s="${s#"${s%%[![:space:]]*}"}"   # ltrim
  s="${s%"${s##*[![:space:]]}"}"   # rtrim
  printf '%s' "$s"
}

# Consider a token "empty" if, after trimming and stripping quotes, nothing remains
is_empty_token() {
  local t
  t=$(trim "$1")
  t=${t%$'\r'}  # strip CR if present

  # Strip surrounding quotes if present
  if [[ "$t" =~ ^\"(.*)\"$ ]]; then
    t="${BASH_REMATCH[1]}"
    t=$(trim "$t")
  fi

  [[ -z "$t" ]]
}

# -------------------------------------------------------------------
# Read SIP & DISP arrays from config
# -------------------------------------------------------------------
sip_line=$(grep '^%SUBSCR_SIP_UA_DATA_SIP_NAME%' "$CFG_FILE" || true)
if [[ -z "$sip_line" ]]; then
  echo "ERROR: %SUBSCR_SIP_UA_DATA_SIP_NAME% not found in config." >&2
  exit 1
fi
sip_payload=${sip_line#*:}
IFS=',' read -r -a SIP_ARR <<< "$sip_payload"
len=${#SIP_ARR[@]}

disp_line=$(grep '^%SUBSCR_UA_DATA_DISP_NAME%' "$CFG_FILE" || true)
if [[ -z "$disp_line" ]]; then
  echo "ERROR: %SUBSCR_UA_DATA_DISP_NAME% not found in config." >&2
  exit 1
fi
disp_payload=${disp_line#*:}
IFS=',' read -r -a DISP_ARR <<< "$disp_payload"

if (( ${#DISP_ARR[@]} != len )); then
  echo "ERROR: SIP_NAME and DISP_NAME length mismatch." >&2
  exit 1
fi

# -------------------------------------------------------------------
# Find ALL completely empty slots (SIP + DISP both empty)
# -------------------------------------------------------------------
free_slots=()
for (( i=0; i<len; i++ )); do
  if is_empty_token "${SIP_ARR[i]}" && is_empty_token "${DISP_ARR[i]}"; then
    free_slots+=("$i")
  fi
done

if (( ${#free_slots[@]} < TOTAL )); then
  echo "ERROR: Not enough empty slots. Found ${#free_slots[@]}, need $TOTAL." >&2
  exit 1
fi

# -------------------------------------------------------------------
# Global arrays for all new devices (index = SIP/DISP column)
# -------------------------------------------------------------------
declare -a HS_VAL CONFIG_VAL TIMEOUT_VAL SIP_VAL
declare -a AUTHNAME_VAL AUTHPASS_VAL DISP_VAL CONFID_VAL

for (( i=0; i<len; i++ )); do
  HS_VAL[i]=""
  CONFIG_VAL[i]=""
  TIMEOUT_VAL[i]=""
  SIP_VAL[i]=""
  AUTHNAME_VAL[i]=""
  AUTHPASS_VAL[i]=""
  DISP_VAL[i]=""
  CONFID_VAL[i]=""
done

max_slot=-1
free_idx=0

# Helper: given existing numbers + needed count, return assigned numbers
assign_with_gaps() {
  local -a existing=()
  local max needed
  local -a out=()

  # args:
  #   $1 = pattern string for grep in DISP ("VocoVoice", "VocoPhone"...)
  #   $2 = needed count
  local pattern="$1"
  needed=$2

  max=0
  existing=()

  # collect existing numbers for this pattern from DISP
  local tok t num
  for tok in "${DISP_ARR[@]}"; do
    t=$(trim "$tok")
    if [[ "$t" =~ ^\"${pattern}[[:space:]]+([0-9]+)\"$ ]]; then
      num="${BASH_REMATCH[1]}"
      existing+=( "$num" )
      (( num > max )) && max=$num
    fi
  done

  # fill gaps 1..max
  local cand=1 used u next_num
  while (( cand <= max && ${#out[@]} < needed )); do
    used=0
    if (( ${#existing[@]} > 0 )); then
      for u in "${existing[@]}"; do
        if (( cand == u )); then
          used=1; break
        fi
      done
    fi
    (( used == 0 )) && out+=( "$cand" )
    ((cand++))
  done

  next_num=$((max + 1))
  while (( ${#out[@]} < needed )); do
    out+=( "$next_num" )
    ((next_num++))
  done

  printf '%s\n' "${out[*]}"
}

# -------------------------------------------------------------------
# 1) Headsets (VocoVoice)
# -------------------------------------------------------------------
if (( QTY_HEADSET > 0 )); then
  # get assigned numbers as space-separated string, then into array
  read -r -a headset_nums <<< "$(assign_with_gaps "VocoVoice" "$QTY_HEADSET")"

  for (( k=0; k<QTY_HEADSET; k++ )); do
    slot_idx=${free_slots[free_idx]}; ((free_idx++))
    num=${headset_nums[k]}
    num3=$(printf "%03d" "$num")

    HS_VAL[slot_idx]="$slot_idx"
    CONFIG_VAL[slot_idx]="0x01"
    TIMEOUT_VAL[slot_idx]="0x5B"
    CONFID_VAL[slot_idx]="0x01"

    SIP_VAL[slot_idx]="\"VOCO_V${num3}\""
    AUTHNAME_VAL[slot_idx]="\"vocov${num3}\""

    a=${num3:0:1}; b=${num3:1:1}; c=${num3:2:1}
    pass3="${c}${b}${a}"
    AUTHPASS_VAL[slot_idx]="\"${pass3}vocov\""

    DISP_VAL[slot_idx]="\"VocoVoice ${num}\""

    (( slot_idx > max_slot )) && max_slot=$slot_idx
  done
fi

# -------------------------------------------------------------------
# 2) Handsets (VocoPhone)
# -------------------------------------------------------------------
if (( QTY_HANDSET > 0 )); then
  read -r -a handset_nums <<< "$(assign_with_gaps "VocoPhone" "$QTY_HANDSET")"

  for (( k=0; k<QTY_HANDSET; k++ )); do
    slot_idx=${free_slots[free_idx]}; ((free_idx++))
    num=${handset_nums[k]}
    num3=$(printf "%03d" "$num")

    HS_VAL[slot_idx]="$slot_idx"
    CONFIG_VAL[slot_idx]="0x01"
    TIMEOUT_VAL[slot_idx]="0x5B"
    CONFID_VAL[slot_idx]="0x01"

    SIP_VAL[slot_idx]="\"VOCO_P${num3}\""
    AUTHNAME_VAL[slot_idx]="\"vocop${num3}\""

    a=${num3:0:1}; b=${num3:1:1}; c=${num3:2:1}
    pass3="${c}${b}${a}"        # 001 -> 100
    AUTHPASS_VAL[slot_idx]="\"${pass3}pocov\""

    DISP_VAL[slot_idx]="\"VocoPhone ${num}\""

    (( slot_idx > max_slot )) && max_slot=$slot_idx
  done
fi

# -------------------------------------------------------------------
# 3) Keypads (VocoMessage)
# -------------------------------------------------------------------
if (( QTY_KEYPAD > 0 )); then
  read -r -a keypad_nums <<< "$(assign_with_gaps "VocoMessage" "$QTY_KEYPAD")"

  for (( k=0; k<QTY_KEYPAD; k++ )); do
    slot_idx=${free_slots[free_idx]}; ((free_idx++))
    num=${keypad_nums[k]}
    num3=$(printf "%03d" "$num")

    HS_VAL[slot_idx]="$slot_idx"
    CONFIG_VAL[slot_idx]="0x01"
    TIMEOUT_VAL[slot_idx]="0x5B"
    CONFID_VAL[slot_idx]="0xFF"

    SIP_VAL[slot_idx]="\"VOCO_K${num3}\""
    AUTHNAME_VAL[slot_idx]="\"vocok${num3}\""

    a=${num3:0:1}; b=${num3:1:1}; c=${num3:2:1}
    pass3="${c}${b}${a}"
    AUTHPASS_VAL[slot_idx]="\"${pass3}kocov\""

    DISP_VAL[slot_idx]="\"VocoMessage ${num}\""

    (( slot_idx > max_slot )) && max_slot=$slot_idx
  done
fi

# -------------------------------------------------------------------
# 4) Call points (VocoTouch)
# -------------------------------------------------------------------
if (( QTY_CALLPOINT > 0 )); then
  read -r -a callpoint_nums <<< "$(assign_with_gaps "VocoTouch" "$QTY_CALLPOINT")"

  for (( k=0; k<QTY_CALLPOINT; k++ )); do
    slot_idx=${free_slots[free_idx]}; ((free_idx++))
    disp_num=${callpoint_nums[k]}          # VocoTouch display number (1,2,...)
    code_num=$((disp_num + 100))           # 1 -> 101, 2 -> 102, ...
    code3=$(printf "%03d" "$code_num")

    HS_VAL[slot_idx]="$slot_idx"
    CONFIG_VAL[slot_idx]="0x01"
    TIMEOUT_VAL[slot_idx]="0x5B"
    CONFID_VAL[slot_idx]="0xFF"

    SIP_VAL[slot_idx]="\"VOCO_K${code3}\""
    AUTHNAME_VAL[slot_idx]="\"vocok${code3}\""

    a=${code3:0:1}; b=${code3:1:1}; c=${code3:2:1}
    pass3="${c}${b}${a}"                  # 101 -> 101, 102 -> 201, etc.
    AUTHPASS_VAL[slot_idx]="\"${pass3}kocov\""

    DISP_VAL[slot_idx]="\"VocoTouch ${disp_num}\""

    (( slot_idx > max_slot )) && max_slot=$slot_idx
  done
fi

# -------------------------------------------------------------------
# Build final CSV lines from global arrays
# -------------------------------------------------------------------
build_line() {
  local kind="$1"
  local result=""
  local idx val

  if (( max_slot < 0 )); then
    echo ""
    return
  fi

  for (( idx=0; idx<=max_slot; idx++ )); do
    case "$kind" in
      hs)  val="${HS_VAL[idx]}" ;;
      cfg) val="${CONFIG_VAL[idx]}" ;;
      to)  val="${TIMEOUT_VAL[idx]}" ;;
      sip) val="${SIP_VAL[idx]}" ;;
      an)  val="${AUTHNAME_VAL[idx]}" ;;
      ap)  val="${AUTHPASS_VAL[idx]}" ;;
      dn)  val="${DISP_VAL[idx]}" ;;
      cid) val="${CONFID_VAL[idx]}" ;;
      *)   val="" ;;
    esac

    if [[ -n "$val" ]]; then
      result+="${val},"
    else
      result+=","
    fi
  done

  printf '%s\n' "$result"
}

IDX_STR=$(build_line hs)
CONFIG_STR=$(build_line cfg)
TIMEOUT_STR=$(build_line to)
SIP_STR=$(build_line sip)
AUTH_NAME_STR=$(build_line an)
AUTH_PASS_STR=$(build_line ap)
DISP_NAME_STR=$(build_line dn)
CONF_ID_STR=$(build_line cid)

# -------------------------------------------------------------------
# Write single additions file with all new devices
# -------------------------------------------------------------------
BASE_DIR=$(dirname "$CFG_FILE")
OUT_FILE="${CUSTOMER}_additions.cfg"
OUT_PATH="${BASE_DIR%/}/$OUT_FILE"

cat > "$OUT_PATH" <<EOF
//Device registration configuration for customer: ${CUSTOMER}
%SUBSCR_SIP_HS_IDX%:${IDX_STR}
%SUBSCR_SIP_UA_DATA_CONFIGURED%:${CONFIG_STR}
%SUBSCR_SIP_UA_DATA_INCOMING_CALL_TIMEOUT%:${TIMEOUT_STR}
%SUBSCR_SIP_UA_DATA_SIP_NAME%:${SIP_STR}
%SUBSCR_SIP_UA_DATA_AUTH_NAME%:${AUTH_NAME_STR}
%SUBSCR_SIP_UA_DATA_AUTH_PASS%:${AUTH_PASS_STR}
%SUBSCR_UA_DATA_DISP_NAME%:${DISP_NAME_STR}
%SUBSCR_UA_DATA_DEFAULT_CONFERENCE_ID%:${CONF_ID_STR}
EOF

echo
printf "%b\n" "${GREEN}Created: ${QTY_HEADSET} headsets, ${QTY_HANDSET} handsets, ${QTY_KEYPAD} keypads, ${QTY_CALLPOINT} call points (total ${TOTAL})${NC}"
echo "Generated config saved to: $OUT_PATH"
