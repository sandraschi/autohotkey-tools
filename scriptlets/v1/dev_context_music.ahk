#NoEnv
#SingleInstance Force
#MaxHotkeysPerInterval 200
#Persistent
SetWorkingDir %A_ScriptDir%

; ========================================
; CONFIGURATION
; ========================================

; Plex configuration (optional)
PlexServer := "http://localhost:32400"
PlexToken := "YOUR_PLEX_TOKEN"  ; Replace with your Plex token

; Music library paths (fallback if Plex is not available)
MusicLibrary := "C:\Users\%A_UserName%\Music\"

; ========================================
; MUSIC TRACKS
; ========================================

; Build Status Tracks
BuildSuccessTracks := ["military_reveille.mp3", "hallelujah_chorus.mp3"]
BuildFailureTracks := ["taps.mp3", "chopin_funeral_march.mp3"]

; Repository Health Tracks
RepoBadTracks := ["the_good_the_bad.mp3", "o_fortuna.mp3"]
RepoDirtyTracks := ["flight_of_the_bumblebee.mp3", "william_tell_overture.mp3"]

; Code Quality Tracks
TestFailureTracks := ["another_one_bites_the_dust.mp3", "chopin_raindrop_prelude.mp3"]
TestSuccessTracks := ["we_are_the_champions.mp3", "beethoven_ode_to_joy.mp3"]

; Time-based Tracks
LateNightTracks := ["chopsticks.mp3", "moonlight_sonata_3rd_mov.mp3"]
EarlyMorningTracks := ["here_comes_the_sun.mp3", "vivaldi_spring.mp3"]
LongSessionTracks := ["time_pink_floyd.mp3", "bohemian_rhapsody.mp3"]

; Emotional Tracks
SadMarches := ["chopin_funeral_march.mp3", "beethoven_eroica_funeral_march.mp3"]
TriumphantTracks := ["pomp_and_circumstance.mp3", "ride_of_the_valkyries.mp3"]

; ========================================
; MAIN FUNCTIONS
; ========================================

; Play a random track from a list
PlayTrack(trackList) {
    Random, rand, 1, % trackList.MaxIndex()
    track := trackList[rand]
    
    ; First try Plex
    if (PlexToken != "YOUR_PLEX_TOKEN") {
        if (PlayPlexTrack(track)) {
            return true
        }
    }
    
    ; Fallback to local files
    if (FileExist(MusicLibrary . track)) {
        SoundPlay, % MusicLibrary . track
        return true
    }
    
    ; Fallback to system sounds
    SoundPlay, *
    return false
}

; Play a track from Plex
PlayPlexTrack(trackName) {
    try {
        ; This is a simplified example - you'd need to implement Plex API calls
        ; to search and play tracks from your Plex library
        Run, "C:\Program Files (x86)\Plex\Plex Media Player\PlexMediaPlayer.exe" --fullscreen --tv --playback=1 "Plex Track"
        return true
    }
    return false
}

; ========================================
; CONTEXT-AWARE MUSIC TRIGGERS
; ========================================

; Check build status (example implementation)
CheckBuildStatus() {
    ; This would check your build system
    ; For now, we'll just return a random status
    Random, status, 1, 10
    if (status > 7) {
        PlayTrack(BuildFailureTracks)
        TrayTip, Build Status, Build failed! Playing sad music..., , 1
    } else {
        PlayTrack(BuildSuccessTracks)
        TrayTip, Build Status, Build succeeded! Celebrating..., , 1
    }
    SetTimer(RemoveTrayTip,  -3000
}

; Check repository health (example implementation)
CheckRepoHealth() {
    ; This would check git status, number of changes, etc.
    ; For now, we'll just return a random status
    Random, status, 1, 10
    if (status > 8) {
        PlayTrack(RepoBadTracks)
        TrayTip, Repository Health, Critical issues found! Playing dramatic music..., , 1
    } else if (status > 5) {
        PlayTrack(RepoDirtyTracks)
        TrayTip, Repository Health, Many uncommitted changes. Time to commit!, , 1
    }
    SetTimer(RemoveTrayTip,  -3000
}

; ========================================
; MANUAL TRIGGERS
; ========================================

; Play a sad march
^!s::  ; Ctrl+Alt+S for sad march
    PlayTrack(SadMarches)
    TrayTip, Mood Music, Playing a sad march..., , 1
    SetTimer(RemoveTrayTip,  -3000
    return

; Play a triumphant piece
^!t::  ; Ctrl+Alt+T for triumphant music
    PlayTrack(TriumphantTracks)
    TrayTip, Mood Music, Playing something triumphant!, , 1
    SetTimer(RemoveTrayTip,  -3000
    return

; Play a random Betty Boop cartoon (Plex)
^!b::  ; Ctrl+Alt+B for Betty Boop
    PlayPlexTrack("Betty Boop")
    TrayTip, Plex, Playing Betty Boop..., , 1
    SetTimer(RemoveTrayTip,  -3000
    return

; Play a random classical piece
^!c::  ; Ctrl+Alt+C for classical
    allClassical := [].Append(BuildSuccessTracks, BuildFailureTracks, SadMarches, TriumphantTracks)
    PlayTrack(allClassical)
    TrayTip, Classical Music, Playing a classical piece..., , 1
    SetTimer(RemoveTrayTip,  -3000
    return

; ========================================
; TIME-BASED TRIGGERS
; ========================================

; Check time and play appropriate music
CheckTime() {
    FormatTime, hour,, H  ; 24-hour format
    
    if (hour >= 22 || hour < 6) {
        ; Late night coding
        if (Random(1, 3) = 1) {  ; 1 in 3 chance
            PlayTrack(LateNightTracks)
            TrayTip, Late Night, Playing some late night coding music..., , 1
            SetTimer(RemoveTrayTip,  -3000
        }
    } else if (hour >= 5 && hour < 9) {
        ; Early morning
        if (Random(1, 4) = 1) {  ; 1 in 4 chance
            PlayTrack(EarlyMorningTracks)
            TrayTip, Good Morning, Rise and shine!, , 1
            SetTimer(RemoveTrayTip,  -3000
        }
    }
}

; ========================================
; HELPER FUNCTIONS
; ========================================

; Generate random number between min and max
Random(min, max) {
    Random, r, min, max
    return r
}

RemoveTrayTip:
    TrayTip
    return

; ========================================
; AUTOMATIC CHECKS
; ========================================

; Check time every 30 minutes
SetTimer(CheckTime,  1800000

; Check repository health every hour
SetTimer(CheckRepoHealth,  3600000

; ========================================
; TRAY MENU
; ========================================

Menu, Tray, NoStandard
Menu, Tray, Add, &Open Launcher, ShowLauncher
Menu, Tray, Add
Menu, Tray, Add, &Sad March (Ctrl+Alt+S), PlaySadMarch
Menu, Tray, Add, &Triumphant Music (Ctrl+Alt+T), PlayTriumphant
Menu, Tray, Add, &Betty Boop (Ctrl+Alt+B), PlayBettyBoop
Menu, Tray, Add, &Classical (Ctrl+Alt+C), PlayClassical
Menu, Tray, Add
Menu, Tray, Add, &Check Build Status, CheckBuildStatus
Menu, Tray, Add, Check &Repository Health, CheckRepoHealth
Menu, Tray, Add
Menu, Tray, Add, &Reload, ReloadScript
Menu, Tray, Add, E&xit, ExitScript
Menu, Tray, Default, &Open Launcher
Menu, Tray, Tip, Dev Context Music

PlaySadMarch:
    Gosub, ^!s
    return

PlayTriumphant:
    Gosub, ^!t
    return

PlayBettyBoop:
    Gosub, ^!b
    return

PlayClassical:
    Gosub, ^!c
    return

ReloadScript:
    Reload
    return

ExitScript:
    ExitApp
    return

ShowLauncher:
    ; You could add a GUI launcher here
    MsgBox, 64, Dev Context Music, Use the tray menu or hotkeys to control music.`n`nHotkeys:`n- Ctrl+Alt+S: Sad March`n- Ctrl+Alt+T: Triumphant Music`n- Ctrl+Alt+B: Betty Boop`n- Ctrl+Alt+C: Classical Music
    return

; ========================================
; INITIALIZATION
; ========================================

; Show welcome message
TrayTip, Dev Context Music, Music system ready!, , 1
SetTimer(RemoveTrayTip,  -3000

; Initial time check
Gosub, CheckTime
