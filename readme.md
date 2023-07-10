# Invoke-Confetti

## What does it do?
This script displays a burst of confetti on the user's screen with a message shown on top.

## Why?
This was whipped up real fast as a humorous PoC for this Reddit post:
https://www.reddit.com/r/sysadmin/comments/14vfv7e/ceo_wants_computers_to_explode_with_confetti_when/

## How does it work?

Run the script `Invoke-Confetti.ps1` with optional parameter `-LabelText` to customize the message shown to the end-user.

> **Note:** ensure the script AND the video file are in the same directory.

## Example
```powershell
& "C:\path\to\Invoke-Confetti.ps1" -LabelText "Congrats! This is a terrible idea!"
```
## Demo
![example](example.gif)