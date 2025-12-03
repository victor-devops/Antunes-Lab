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
echo "    ================== Headset Slot Generator ==================    ";
echo "                                                                    ";

# Colours
GREEN="\033[0;32m"
NC="\033[0m"

read -rp "Enter the path to base config file: " CFG_FILE
if [[ ! -f "$CFG_FILE" ]]; then
  echo "ERROR: File not found: $CFG_FILE" >&2
  exit 1
fi

read -rp "Enter customer name: " CUSTOMER
read -rp "Number of new headsets to add: " QTY

if ! [[ "$QTY" =~ ^[0-9]+$ ]]; then
  echo "Error: quantity must be an integer." >&2
  exit 1
fi
if (( QTY <= 0 )); then
  echo "Nothing to generate (quantity <= 0)." >&2
  exit 0
fi

trim() {
  local s="$1"
  s="${s#"${s%%[![:space:]]*}"}" 
  s="${s%"${s##*[![:space:]]}"}" 
  printf '%s' "$s"
}

build_line() {
  local kind="$1"
  local result=""
  local cur=0
  local k tgt val

  for ((k=0; k<QTY; k++)); do
    tgt=${target_idxs[k]}
    while ((cur < tgt)); do
      result+=","
      ((cur++))
    done

    case "$kind" in
      hs)   val=${HS_VALUES[k]} ;;
      cfg)  val=${CONFIG_VALUES[k]} ;;
      to)   val=${TIMEOUT_VALUES[k]} ;;
      sip)  val=${SIP_VALUES[k]} ;;
      an)   val=${AUTHNAME_VALUES[k]} ;;
      ap)   val=${AUTHPASS_VALUES[k]} ;;
      dn)   val=${DISP_VALUES[k]} ;;
      cid)  val=${CONFID_VALUES[k]} ;;
      *)    val="" ;;
    esac

    result+="${val},"
    ((cur++))
  done

  printf '%s\n' "$result"
}

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

empty_slots=()
for (( i=0; i<len; i++ )); do
  sip_tok=$(trim "${SIP_ARR[i]}")
  disp_tok=$(trim "${DISP_ARR[i]}")

  if { [[ -z "$sip_tok" ]] || [[ "$sip_tok" == '\"\"' ]] || [[ "$sip_tok" == '""' ]]; } &&
     { [[ -z "$disp_tok" ]] || [[ "$disp_tok" == '\"\"' ]] || [[ "$disp_tok" == '""' ]]; }; then
    empty_slots+=("$i")
  fi
done

if (( ${#empty_slots[@]} < QTY )); then
  echo "ERROR: Not enough empty slots. Found ${#empty_slots[@]}, need $QTY." >&2
  exit 1
fi

target_idxs=("${empty_slots[@]:0:QTY}")

existing_nums=()
max_voice=0

for tok in "${DISP_ARR[@]}"; do
  t=$(trim "$tok")
  if [[ "$t" =~ ^\"VocoVoice[[:space:]]+([0-9]+)\"$ ]]; then
    num="${BASH_REMATCH[1]}"
    existing_nums+=( "$num" )
    (( num > max_voice )) && max_voice=$num
  fi
done

assign_nums=()

cand=1
while (( cand <= max_voice && ${#assign_nums[@]} < QTY )); do
  used=0
  if (( ${#existing_nums[@]} > 0 )); then
    for u in "${existing_nums[@]}"; do
      if (( cand == u )); then
        used=1
        break
      fi
    done
  fi
  (( used == 0 )) && assign_nums+=( "$cand" )
  ((cand++))
done

next_num=$((max_voice + 1))
while (( ${#assign_nums[@]} < QTY )); do
  assign_nums+=( "$next_num" )
  ((next_num++))
done

declare -a HS_VALUES CONFIG_VALUES TIMEOUT_VALUES SIP_VALUES
declare -a AUTHNAME_VALUES AUTHPASS_VALUES DISP_VALUES CONFID_VALUES

for (( k=0; k<QTY; k++ )); do
  slot_idx=${target_idxs[k]}      
  num=${assign_nums[k]}           
  num3=$(printf "%03d" "$num")    

  HS_VALUES[k]="$slot_idx"
  CONFIG_VALUES[k]="0x01"
  TIMEOUT_VALUES[k]="0x5B"
  CONFID_VALUES[k]="0x01"

  SIP_VALUES[k]="\"VOCO_V${num3}\""
  AUTHNAME_VALUES[k]="\"vocov${num3}\""

  a=${num3:0:1}; b=${num3:1:1}; c=${num3:2:1}
  pass3="${c}${b}${a}"
  AUTHPASS_VALUES[k]="\"${pass3}vocov\""

  DISP_VALUES[k]="\"VocoVoice ${num}\""
done

IDX_STR=$(build_line hs)
CONFIG_STR=$(build_line cfg)
TIMEOUT_STR=$(build_line to)
SIP_STR=$(build_line sip)
AUTH_NAME_STR=$(build_line an)
AUTH_PASS_STR=$(build_line ap)
DISP_NAME_STR=$(build_line dn)
CONF_ID_STR=$(build_line cid)

BASE_DIR=$(dirname "$CFG_FILE")
OUT_FILE="${CUSTOMER}_headset.cfg"
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

printf "%b\n" "${GREEN}${QTY} headset slot entries created${NC}"

echo
echo "Generated config saved to: $OUT_PATH"

