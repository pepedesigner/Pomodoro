# Pomodoro

A native SwiftUI Pomodoro timer for macOS with an Apple-style interface: a circular progress ring, large rounded digits, segmented mode picker, and a live countdown in the menu bar.

## Features

- Focus / Short Break / Long Break modes with distinct accent colors
- Animated progress ring and monospaced timer digits
- Start, Pause, Reset, Skip controls
- Settings: durations, long-break interval, auto-start, sound and notifications
- Menu bar countdown with quick controls (timer keeps running when the window is closed)
- System sound + notification when a session ends
- Completed-session counter persisted across launches

## Build

```sh
./Scripts/make_app.sh
```

This compiles the release binary, generates the tomato app icon, and assembles `build/Pomodoro.app`.

## Run

```sh
open build/Pomodoro.app
```

Or, to develop with `swift run`:

```sh
swift run
```

## Requirements

- macOS 14 or later
- Xcode / Swift toolchain (Swift 6+)
