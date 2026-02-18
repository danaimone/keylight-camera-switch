# Keylight Camera Switch

Automatically turns an Elgato Key Light on when your camera is active (e.g. video calls) and off when it stops. Works with any app — Teams, Zoom, FaceTime, etc.

## How it works

- A small Swift helper (`camera-in-use`) checks macOS's CoreMediaIO API (`kCMIODevicePropertyDeviceIsRunningSomewhere`) — the same signal that drives the green dot camera indicator in the menu bar
- A shell script polls every 3 seconds and hits the Key Light's local HTTP API to toggle it
- A Launch Agent keeps it running in the background

## Requirements

- macOS (tested on Sequoia/Tahoe, Apple Silicon)
- Elgato Key Light on your local network
- Xcode Command Line Tools (`xcode-select --install`)

## Setup

```bash
# 1. Clone and enter the repo
git clone https://github.com/YOUR_USER/keylight-camera-switch.git
cd keylight-camera-switch

# 2. Compile the camera detection helper
swiftc -o ~/bin/camera-in-use camera-in-use.swift -framework CoreMediaIO
chmod +x ~/bin/camera-in-use

# 3. Copy the watcher script and make it executable
cp keylight-camera-watcher.sh ~/bin/
chmod +x ~/bin/keylight-camera-watcher.sh

# 4. Edit the config — set your Key Light's IP address and brightness
#    Find your light's IP in the Elgato Control Center app or via:
#    dns-sd -B _elg._tcp
vi ~/bin/keylight-camera-watcher.sh

# 5. Install the Launch Agent
cp com.local.keylight-camera.plist ~/Library/LaunchAgents/
sed -i '' "s|REPLACE_ME|$USER|g" ~/Library/LaunchAgents/com.local.keylight-camera.plist

# 6. Load and start
launchctl bootstrap "gui/$(id -u)" ~/Library/LaunchAgents/com.local.keylight-camera.plist
launchctl kickstart -k "gui/$(id -u)/com.local.keylight-camera"
```

## Troubleshooting

```bash
# Check if the agent is running
launchctl print "gui/$(id -u)/com.local.keylight-camera" | grep state

# Check for errors
tail /tmp/keylight-camera.err

# Check logs
log show --last 10m --predicate 'eventMessage CONTAINS "keylight-camera"' --style compact

# Test camera detection manually
~/bin/camera-in-use && echo "Camera active" || echo "Camera inactive"
```

## Uninstall

```bash
launchctl bootout "gui/$(id -u)/com.local.keylight-camera"
rm ~/Library/LaunchAgents/com.local.keylight-camera.plist
rm ~/bin/keylight-camera-watcher.sh ~/bin/camera-in-use
rm ~/Library/Caches/teams_keylight_state
```
