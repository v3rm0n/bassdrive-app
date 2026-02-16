---
name: release-preview
description: Run Flutter in release mode in the background and manage start/stop/reload for device previews.
license: MIT
compatibility: opencode
---
## What I do
- Start a release-mode `flutter run` in the background for a specific device.
- Track the background process PID so it can be stopped or reloaded.
- Store logs and the last-used device id for quick restarts.

## Files and paths
- State directory: `.opencode/state/`
- PID file: `.opencode/state/release-preview.pid`
- Log file: `.opencode/state/release-preview.log`
- Device file: `.opencode/state/release-preview.device`

## Usage

### Start preview
1) Ensure a device id is available.
   - Use the saved device id if `.opencode/state/release-preview.device` exists.
   - Otherwise, run `flutter devices` and pick the correct id.
2) If a PID exists and the process is alive, report that preview is already running and do nothing.
3) If no live PID is found, start the process in the background and save the PID:

```bash
mkdir -p .opencode/state
nohup flutter run --release -d "<device-id>" > .opencode/state/release-preview.log 2>&1 &
echo $! > .opencode/state/release-preview.pid
printf "%s" "<device-id>" > .opencode/state/release-preview.device
```

### Stop preview
1) If no PID file exists, report nothing is running and exit.
2) If PID exists, terminate it gracefully, then force kill if still running:

```bash
pid="$(cat .opencode/state/release-preview.pid)"
kill "$pid" 2>/dev/null || true
sleep 1
kill -9 "$pid" 2>/dev/null || true
rm -f .opencode/state/release-preview.pid
```

### Reload preview
Run Stop preview, then Start preview (using the saved device id if available).

## Notes
- Release mode on iOS is AOT; there is no hot reload. Reload means stop and re-run.
- Keep the background process running to avoid blocking the agent.
- If the PID file exists but the process is gone, treat it as stale and remove it before starting.
