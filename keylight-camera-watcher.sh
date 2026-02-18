#!/bin/zsh
set -u

KEYLIGHT_HOST="YOUR_KEYLIGHT_IP"
POLL_SECONDS=3
STATE_FILE="$HOME/Library/Caches/keylight_camera_state"

api_put() {
  /usr/bin/curl -fsS -m 4 \
    -H "Content-Type: application/json" \
    -X PUT -d "$1" \
    "http://${KEYLIGHT_HOST}:9123/elgato/lights" >/dev/null 2>&1
}

turn_on()  { api_put '{"numberOfLights":1,"lights":[{"on":1,"brightness":30}]}'; }
turn_off() { api_put '{"numberOfLights":1,"lights":[{"on":0}]}'; }

state="off"
[[ -f "$STATE_FILE" ]] && state="$(<"$STATE_FILE")"

while true; do
  if "$HOME/bin/camera-in-use" && [[ "$state" != "on" ]]; then
    turn_on && state="on" && print -r -- "$state" > "$STATE_FILE"
    logger -t keylight-camera "ON"
  elif ! "$HOME/bin/camera-in-use" && [[ "$state" != "off" ]]; then
    turn_off && state="off" && print -r -- "$state" > "$STATE_FILE"
    logger -t keylight-camera "OFF"
  fi
  sleep "$POLL_SECONDS"
done
