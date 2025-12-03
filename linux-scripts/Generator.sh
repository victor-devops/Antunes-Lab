#!/usr/bin/env bash
set -euo pipefail

echo "=== VoCoVo headset slot generator ==="
read -rp "Enter customer name: " CUSTOMER

# SAME value as in the spreadsheet "Highest current IDX (including conferences)"
read -rp "Highest current IDX (including conferences): " FIRST_IDX

read -rp "Number of new headsets to add: " QTY
read -rp "Start number for new headsets (e.g. 19 for VOCO_V019): " START_NUM

# Basic sanity checks
if ! [[ "$FIRST_IDX" =~ ^[0-9]+$ && "$QTY" =~ ^[0-9]+$ && "$START_NUM" =~ ^[0-9]+$ ]]; then
  echo "Error: idx, quantity and start number must be integers." >&2
  exit 1
fi

if (( QTY <= 0 )); then
  echo "Nothing to generate (quantity <= 0)." >&2
  exit 0
fi

# EXACT padding to match the spreadsheet: 9 commas after the colon
PADDING=$(printf ',%.0s' {1..9})

IDX_STR=""
CONFIG_STR=""
TIMEOUT_STR=""
SIP_STR=""
AUTH_NAME_STR=""
AUTH_PASS_STR=""
DISP_NAME_STR=""
CONF_ID_STR=""

for (( i=0; i<QTY; i++ )); do
  idx=$((FIRST_IDX + i))      # 9 -> 9,10,...
  num=$((START_NUM + i))      # 7 -> 7,8,...
  num3=$(printf "%03d" "$num") # 7 -> 007, 19 -> 019

  # Build password digits: reverse the 3-digit string (CBA)
  a=${num3:0:1}
  b=${num3:1:1}
  c=${num3:2:1}
  pass3="${c}${b}${a}"        # 007 -> 700, 019 -> 910

  IDX_STR+="${idx},"
  CONFIG_STR+="0x01,"
  TIMEOUT_STR+="0x5B,"

  SIP_STR+="\"VOCO_V${num3}\","
  AUTH_NAME_STR+="\"vocov${num3}\","
  AUTH_PASS_STR+="\"${pass3}vocov\","
  DISP_NAME_STR+="\"VocoVoice ${num}\","
  CONF_ID_STR+="0x01,"
done

# Ask where to save
echo
read -rp "Output file name (leave blank to only print on screen): " OUT_FILE
echo

# Build the block once
OUTPUT=$(
  cat <<EOF
//Device registration configuration for customer: ${CUSTOMER}
%SUBSCR_SIP_HS_IDX%:${PADDING}${IDX_STR}
%SUBSCR_SIP_UA_DATA_CONFIGURED%:${PADDING}${CONFIG_STR}
%SUBSCR_SIP_UA_DATA_INCOMING_CALL_TIMEOUT%:${PADDING}${TIMEOUT_STR}
%SUBSCR_SIP_UA_DATA_SIP_NAME%:${PADDING}${SIP_STR}
%SUBSCR_SIP_UA_DATA_AUTH_NAME%:${PADDING}${AUTH_NAME_STR}
%SUBSCR_SIP_UA_DATA_AUTH_PASS%:${PADDING}${AUTH_PASS_STR}
%SUBSCR_UA_DATA_DISP_NAME%:${PADDING}${DISP_NAME_STR}
%SUBSCR_UA_DATA_DEFAULT_CONFERENCE_ID%:${PADDING}${CONF_ID_STR}
EOF
)

# Print + optionally save
if [[ -n "$OUT_FILE" ]]; then
  echo "$OUTPUT" | tee "$OUT_FILE"
  echo
  echo "Config block also saved to: $OUT_FILE"
else
  echo "$OUTPUT"
fi

echo
echo "Copy this block (or the file contents) into your config file."
