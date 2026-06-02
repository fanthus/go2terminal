# Go2Terminal Design Spec

## Overview

Go2Terminal is a macOS utility app that sits in the Finder toolbar. When clicked, it opens a new terminal window at the current Finder directory. It supports both Terminal.app and iTerm2, with a preferences window for configuration.

## Requirements

- **Platform:** macOS
- **Language:** Swift
- **App type:** LSUIElement (no Dock icon)
- **Supported terminals:** Terminal.app, iTerm2
- **Core behavior:** Click icon → get Finder path → open new terminal window at that path
- **Settings:** Preferences window to select default terminal
- **Installation:** Drag .app to Finder toolbar while holding Command key

## Architecture

```
Go2Terminal.app
├── AppDelegate.swift          # App entry, handles toolbar click
├── PreferencesWindow.swift    # Preferences window (terminal selection)
├── FinderPathResolver.swift   # Get current Finder window path via AppleScript
├── TerminalLauncher.swift     # Open terminal via AppleScript
└── Resources/
    ├── Info.plist
    └── Assets.xcassets         # App icon
```

## Core Modules

### FinderPathResolver

Uses NSAppleScript to query the frontmost Finder window's path:

```applescript
tell application "Finder"
    if (count of Finder windows) > 0 then
        return POSIX path of (target of front Finder window as alias)
    else
        return POSIX path of (path to home folder)
    end if
end tell
```

- Returns the POSIX path of the front Finder window's target directory
- Falls back to the user's home directory if no Finder window is open

### TerminalLauncher

Executes AppleScript to open a new terminal window and cd to the target path.

**Terminal.app:**

```applescript
tell application "Terminal"
    activate
    do script "cd '/path/to/dir'"
end tell
```

**iTerm2:**

```applescript
tell application "iTerm"
    activate
    create window with default profile
    tell current session of current window
        write text "cd '/path/to/dir'"
    end tell
end tell
```

- Always opens a new window (not a new tab)
- Path is quoted to handle spaces and special characters

### PreferencesWindow

- Simple window with a dropdown to select the default terminal (Terminal.app / iTerm2)
- Settings stored in `UserDefaults`
- Opened by holding Option key while clicking the Finder toolbar icon

## Interaction Flow

```
User clicks Finder toolbar icon
        │
        ▼
   Option key held? ──yes──▶ Open Preferences window
        │
        no
        ▼
  Get front Finder window path (AppleScript)
        │
        ▼
  Read terminal preference from UserDefaults
        │
        ▼
  Execute AppleScript for chosen terminal
        │
        ▼
  Terminal opens new window, cd to target path
```

## Permissions

- Requires macOS Automation permission to control Finder, Terminal.app, and iTerm2
- On first launch, macOS prompts the user to grant access
- If permission is denied, the app shows an alert guiding the user to System Settings → Privacy & Security → Automation

## Error Handling

| Scenario | Behavior |
|----------|----------|
| No Finder window open | Open user's home directory |
| iTerm2 selected but not installed | Show alert suggesting to switch to Terminal.app |
| Automation permission denied | Show alert with instructions to enable in System Settings |

## Build & Installation

1. Build the Xcode project to produce `Go2Terminal.app`
2. User holds Command key and drags `Go2Terminal.app` to the Finder toolbar
3. Click to use
