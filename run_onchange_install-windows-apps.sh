#!/bin/bash
# Install Windows-side apps (window manager, status bar, launcher) — only applicable when running WSL on Windows.
# Edit the list below to change what's installed; chezmoi re-runs this script when its content changes.

# Only applicable under WSL
grep -qi microsoft /proc/version 2>/dev/null || exit 0

cd /mnt/c || exit 1

for id in \
  glzr-io.glazewm \
  AmN.yasb \
  Flow-Launcher.Flow-Launcher
do
  if winget.exe list --id "$id" -e --accept-source-agreements >/dev/null 2>&1; then
    echo "$id already installed"
  else
    winget.exe install --id "$id" -e --accept-package-agreements --accept-source-agreements --disable-interactivity
  fi
done

# Launch Flow Launcher (Alt+Space) at login via a shortcut in the user's Startup folder
powershell.exe -NoProfile -Command '
  $lnk = Join-Path ([Environment]::GetFolderPath("Startup")) "Flow Launcher.lnk"
  $s = (New-Object -ComObject WScript.Shell).CreateShortcut($lnk)
  $s.TargetPath = "$env:LOCALAPPDATA\FlowLauncher\Flow.Launcher.exe"
  $s.Save()
' && echo "Flow Launcher added to Windows startup"
