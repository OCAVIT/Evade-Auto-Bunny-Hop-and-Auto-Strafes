﻿#SingleInstance Force
#InstallKeybdHook
SetBatchLines, -1
SendMode Input

; === Settings ===
ToggleKey   := "Shift"
ForwardKey  := "w"
LeftKey     := "a"
RightKey    := "d"
JumpKey     := "Space"

; === Variables ===
autoRun := false
groundStrafeState := 0   ; 0 - A, 1 - D
aDown := false
dDown := false
spaceDown := false

; === Hotkeys ===
Hotkey, % "*" . ToggleKey, ToggleAutoRun
Hotkey, % "*" . JumpKey, SpaceDown
Hotkey, % "*" . JumpKey . " up", SpaceUp

ToggleAutoRun:
    autoRun := !autoRun
    if (autoRun) {
        SendInput, {Blind}{%ForwardKey% down}
        SetTimer, GroundStrafe, 20
        SetTimer, MouseStrafe, 10
        SetTimer, AutoJump, 10
    } else {
        SendInput, {Blind}{%ForwardKey% up}
        SetTimer, GroundStrafe, Off
        SetTimer, MouseStrafe, Off
        SetTimer, AutoJump, Off
        if (aDown) {
            SendInput, {Blind}{%LeftKey% up}
            aDown := false
        }
        if (dDown) {
            SendInput, {Blind}{%RightKey% up}
            dDown := false
        }
    }
return

SpaceDown:
    spaceDown := true
return

SpaceUp:
    spaceDown := false
    ; Отпускаем A и D при отпускании пробела
    if (aDown) {
        SendInput, {Blind}{%LeftKey% up}
        aDown := false
    }
    if (dDown) {
        SendInput, {Blind}{%RightKey% up}
        dDown := false
    }
return

; === GROUND STRAFE (only if the space bar is NOT clamped) ===
GroundStrafe:
    if (!autoRun || spaceDown)
        return
    if (groundStrafeState = 0) {
        if (dDown) {
            SendInput, {Blind}{%RightKey% up}
            dDown := false
        }
        if (!aDown) {
            SendInput, {Blind}{%LeftKey% down}
            aDown := true
        }
        groundStrafeState := 1
    } else {
        if (aDown) {
            SendInput, {Blind}{%LeftKey% up}
            aDown := false
        }
        if (!dDown) {
            SendInput, {Blind}{%RightKey% down}
            dDown := true
        }
        groundStrafeState := 0
    }
return

; === MOUSE STRAFE (only if you hold down the space bar) ===
MouseStrafe:
    if (!autoRun || !spaceDown)
        return
    FileRead, cmd, C:\temp\evade_cmd.txt
    cmd := Trim(cmd)
    if (cmd = "A") {
        if (!aDown) {
            SendInput, {Blind}{%LeftKey% down}
            aDown := true
        }
        if (dDown) {
            SendInput, {Blind}{%RightKey% up}
            dDown := false
        }
    } else if (cmd = "D") {
        if (!dDown) {
            SendInput, {Blind}{%RightKey% down}
            dDown := true
        }
        if (aDown) {
            SendInput, {Blind}{%LeftKey% up}
            aDown := false
        }
    } else {
        if (aDown) {
            SendInput, {Blind}{%LeftKey% up}
            aDown := false
        }
        if (dDown) {
            SendInput, {Blind}{%RightKey% up}
            dDown := false
        }
    }
return

; === AutoJump (only if you hold down the space bar) ===
AutoJump:
    if (!autoRun || !spaceDown)
        return
    SendInput, {Blind}{%JumpKey% down}
    Sleep, 15
    SendInput, {Blind}{%JumpKey% up}
    Sleep, 5
return

; === RELEASING EVERYTHING WHEN THE SCRIPT IS TURNED OFF ===
OnExit:
    if (aDown)
        SendInput, {Blind}{%LeftKey% up}
    if (dDown)
        SendInput, {Blind}{%RightKey% up}
    if (autoRun)
        SendInput, {Blind}{%ForwardKey% up}
ExitApp
return
