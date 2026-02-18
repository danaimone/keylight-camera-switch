#!/bin/zsh
set -u

#--- Config ---

KEYLIGHT_HOST="YOUR_KEYLIGHT_IP"
POLL_SECONDS=3
STATE_FILE="$HOME/Library/Caches/keylight_camera_state"

api_put() {
  local payload="$1"
  /usr/bin/curl -fsS -m 4 \
    -H "Content-Type: application/json" \
    -X PUT \
    -d "$payload" \
    "http://${KEYLIGHT_HOST}:9123/elgato/lights" >/dev/null 2>&1
}

turn_on()  { api_put '{"numberOfLights":1,"lights":[{"on":1,"brightness":30}]}'; }
turn_off() { api_put '{"numberOfLights":1,"lights":[{"on":0}]}'; }

camera_in_use() {
  "$HOME/bin/camera-in-use"
}

state="off"
[[ -f "$STATE_FILE" ]] && state="$(<"$STATE_FILE")"

while true; do
  if camera_in_use; then
    want_on=true
  else
    want_on=false
  fi

  if [[ "$want_on" = "true" && "$state" != "on" ]]; then
    turn_on && state="on" && print -r -- "$state" > "$STATE_FILE"
    logger -t keylight-camera "ON"
  elif [[ "$want_on" != "true" && "$state" != "off" ]]; then
    turn_off && state="off" && print -r -- "$state" > "$STATE_FILE"
    logger -t keylight-camera "OFF"
  fi

  sleep "$POLL_SECONDS"
done
