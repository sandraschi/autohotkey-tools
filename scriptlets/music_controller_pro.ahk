; ==============================================================================
; Music Controller Pro
; @name: Music Controller Pro
; @version: 2.0.0
; @description: Lightweight playlist launcher with simulated playback, logging, and safe hotkeys.
; @category: media
; @author: Sandra
; @hotkeys: #Space, #Left, #Right, #Up, #Down, #M, F9
; @enabled: true
; @priority: 35
; @tag: music, playlist, productivity, gui
; ==============================================================================

#Requires AutoHotkey v2.0+
#SingleInstance Force
#Include %A_ScriptDir%\lib\ScriptletErrorHandler.ahk

OnError(LogError)

class MusicControllerPro {
    static gui := ""
    static playlistCombo := ""
    static trackList := ""
    static progressBar := ""
    static currentTrackInfo := ""
    static volumeSlider := ""
    static volumeLabel := ""
    static statusBar := ""
    static timerRef := ""
    static playlists := Map()
    static playlistOrder := []
    static currentPlaylist := ""
    static currentTrackIndex := -1
    static isPlaying := false
    static repeatEnabled := false
    static volume := 60
    static hotkeysRegistered := false
    static logDir := ""
    static logFile := ""

    static HandleScriptError(Thrown, Mode) {
        return ScriptletErrorHandler.Handle(Thrown, Mode)
    }

    static Init() {
        MusicControllerPro.EnsureLogging()
        MusicControllerPro.SeedPlaylists()
        if (!MusicControllerPro.gui) {
            MusicControllerPro.CreateGui()
            MusicControllerPro.SetupHotkeys()
            MusicControllerPro.AppendLog("Music Controller initialised.")
        }
        MusicControllerPro.ShowGui()
        MusicControllerPro.UpdateTrackList()
    }

    static EnsureLogging() {
        if (MusicControllerPro.logDir) {
            return
        }
        logDirectory := A_ScriptDir . "\logs"
        if (!DirExist(logDirectory)) {
            DirCreate(logDirectory)
        }
        MusicControllerPro.logDir := logDirectory
        MusicControllerPro.logFile := logDirectory . "\music_controller_pro.log"
    }

    static AppendLog(message, level := "INFO") {
        timestamp := ""
        timestamp := FormatTime(, "yyyy-MM-dd HH:mm:ss")
        line := "[" . timestamp . "] [" . level . "] " . message . "`n"
        try {
            FileAppend(line, MusicControllerPro.logFile, "UTF-8")
        } catch {
            ; ignore logging failures
        }
        OutputDebug("MusicControllerPro: " . message)
    }

    static SeedPlaylists() {
        if (MusicControllerPro.playlists.Length) {
            return
        }
        MusicControllerPro.AddPlaylist("Chill", [
            Map("title", "Evening Lofi", "duration", "3:12"),
            Map("title", "Rainy Window", "duration", "4:05"),
            Map("title", "Soft Piano", "duration", "2:58")
        ])
        MusicControllerPro.AddPlaylist("Focus", [
            Map("title", "Deep Work Synth", "duration", "5:21"),
            Map("title", "Ambient Strings", "duration", "4:44"),
            Map("title", "Quiet Library", "duration", "3:37")
        ])
        MusicControllerPro.AddPlaylist("Workout", [
            Map("title", "Interval Beats", "duration", "3:30"),
            Map("title", "Cardio Rush", "duration", "4:10"),
            Map("title", "Victory Lap", "duration", "3:48")
        ])
        MusicControllerPro.currentPlaylist := "Chill"
    }

    static AddPlaylist(name, tracks) {
        if (MusicControllerPro.playlists.Has(name)) {
            MusicControllerPro.playlists[name] := tracks
            return
        }
        MusicControllerPro.playlists[name] := tracks
        MusicControllerPro.playlistOrder.Push(name)
    }

    static CreateGui() {
        MusicControllerPro.gui := Gui("+Resize +MinSize420x360", "Music Controller Pro")
        MusicControllerPro.gui.SetFont("s10", "Segoe UI")
        MusicControllerPro.gui.OnEvent("Close", MusicControllerPro.HideGui.Bind(MusicControllerPro))
        MusicControllerPro.gui.OnEvent("Escape", MusicControllerPro.HideGui.Bind(MusicControllerPro))
        MusicControllerPro.gui.OnEvent("Size", MusicControllerPro.HandleResize.Bind(MusicControllerPro))

        MusicControllerPro.gui.Add("Text", "x12 y10 w200 h22", "Playlist:")
        items := []
        for name in MusicControllerPro.playlistOrder {
            items.Push(name)
        }
        MusicControllerPro.playlistCombo := MusicControllerPro.gui.Add("DropDownList", "x12 y32 w200", items)
        MusicControllerPro.playlistCombo.Text := MusicControllerPro.currentPlaylist
        MusicControllerPro.playlistCombo.OnEvent("Change", MusicControllerPro.HandlePlaylistChange.Bind(MusicControllerPro))
        newButton := MusicControllerPro.gui.Add("Button", "x224 y32 w80 h24", "New…")
        newButton.OnEvent("Click", MusicControllerPro.CreatePlaylistDialog.Bind(MusicControllerPro))

        MusicControllerPro.gui.Add("Text", "x12 y70 w380 h20", "Tracks:")
        MusicControllerPro.trackList := MusicControllerPro.gui.Add("ListView", "x12 y92 w388 h150 -Multi", ["#", "Title", "Duration", "State"])
        MusicControllerPro.trackList.OnEvent("DoubleClick", MusicControllerPro.PlaySelected.Bind(MusicControllerPro))
        MusicControllerPro.trackList.ModifyCol(1, 30)
        MusicControllerPro.trackList.ModifyCol(2, 210)
        MusicControllerPro.trackList.ModifyCol(3, 70)
        MusicControllerPro.trackList.ModifyCol(4, 60)

        buttonGroup := MusicControllerPro.gui.Add("GroupBox", "x12 y250 w388 h70", "Controls")
        MusicControllerPro.AddButton("Prev", 24, 274, MusicControllerPro.PreviousTrack.Bind(MusicControllerPro))
        MusicControllerPro.AddButton("Play", 104, 274, MusicControllerPro.TogglePlayback.Bind(MusicControllerPro))
        MusicControllerPro.AddButton("Stop", 184, 274, MusicControllerPro.StopPlayback.Bind(MusicControllerPro))
        MusicControllerPro.AddButton("Next", 264, 274, MusicControllerPro.NextTrack.Bind(MusicControllerPro))
        MusicControllerPro.AddButton("Random", 344, 274, MusicControllerPro.PlayRandom.Bind(MusicControllerPro))

        MusicControllerPro.gui.Add("Text", "x12 y330 w100 h20", "Volume:")
        MusicControllerPro.volumeSlider := MusicControllerPro.gui.Add("Slider", "x70 y330 w200 h24 Range0-100 ToolTip", MusicControllerPro.volume)
        MusicControllerPro.volumeSlider.OnEvent("Change", MusicControllerPro.HandleVolumeChange.Bind(MusicControllerPro))
        MusicControllerPro.volumeLabel := MusicControllerPro.gui.Add("Text", "x280 y330 w60 h20", MusicControllerPro.volume . "%")
        repeatBox := MusicControllerPro.gui.Add("CheckBox", "x340 y330 w80 h20", "Repeat")
        repeatBox.Value := MusicControllerPro.repeatEnabled ? 1 : 0
        repeatBox.OnEvent("Click", (*) => MusicControllerPro.ToggleRepeat())

        MusicControllerPro.gui.Add("Text", "x12 y360 w380 h20", "Now playing:")
        MusicControllerPro.currentTrackInfo := MusicControllerPro.gui.Add("Text", "x12 y382 w388 h36", "Nothing playing")

        MusicControllerPro.gui.Add("Text", "x12 y420 w388 h20", "Progress:")
        MusicControllerPro.progressBar := MusicControllerPro.gui.Add("Progress", "x12 y442 w388 h18", 0)

        MusicControllerPro.statusBar := MusicControllerPro.gui.Add("StatusBar")
        MusicControllerPro.UpdateStatus("Ready. Use Win+M to toggle.")
    }

    static AddButton(text, x, y, callback) {
        btn := MusicControllerPro.gui.Add("Button", Format("x{} y{} w70 h24", x, y), text)
        btn.OnEvent("Click", callback)
        return btn
    }

    static SetupHotkeys() {
        if (MusicControllerPro.hotkeysRegistered) {
            return
        }
        Hotkey("#Space", (*) => MusicControllerPro.TogglePlayback(), "On")
        Hotkey("#Left", (*) => MusicControllerPro.PreviousTrack(), "On")
        Hotkey("#Right", (*) => MusicControllerPro.NextTrack(), "On")
        Hotkey("#Up", (*) => MusicControllerPro.AdjustVolume(5), "On")
        Hotkey("#Down", (*) => MusicControllerPro.AdjustVolume(-5), "On")
        Hotkey("#M", (*) => MusicControllerPro.ToggleGui(), "On")
        Hotkey("F9", (*) => MusicControllerPro.EmergencyStop(), "On")
        MusicControllerPro.hotkeysRegistered := true
    }

    static ToggleGui(*) {
        if (!MusicControllerPro.gui) {
            MusicControllerPro.Init()
            return
        }
        if (MusicControllerPro.gui.Visible) {
            MusicControllerPro.HideGui()
        } else {
            MusicControllerPro.ShowGui()
        }
    }

    static ShowGui() {
        MusicControllerPro.gui.Show("Center")
        MusicControllerPro.UpdateStatus("Use Win+Space to play/pause.")
    }

    static HideGui(*) {
        if (MusicControllerPro.gui) {
            MusicControllerPro.gui.Hide()
        }
    }

    static UpdateStatus(message) {
        if (MusicControllerPro.statusBar) {
            MusicControllerPro.statusBar.SetText(message, 1)
        }
    }

    static EmergencyStop(*) {
        MusicControllerPro.StopPlayback()
        MusicControllerPro.HideGui()
        MusicControllerPro.AppendLog("Emergency stop triggered.", "WARN")
        MusicControllerPro.UpdateStatus("Emergency stop triggered. Playback halted.")
    }

    static HandleResize(gui, minMax, width, height) {
        if (!MusicControllerPro.gui) {
            return
        }
        padding := 12
        MusicControllerPro.trackList.Move(padding, 92, width - padding * 2, Max(80, height - 230))
        MusicControllerPro.progressBar.Move(padding, height - 38, width - padding * 2, 18)
        MusicControllerPro.statusBar.SetParts([width - padding * 2])
    }

    static HandlePlaylistChange(*) {
        MusicControllerPro.currentPlaylist := MusicControllerPro.playlistCombo.Text
        MusicControllerPro.currentTrackIndex := -1
        MusicControllerPro.StopPlayback()
        MusicControllerPro.UpdateTrackList()
        MusicControllerPro.AppendLog("Playlist changed to " . MusicControllerPro.currentPlaylist)
    }

    static UpdateTrackList() {
        MusicControllerPro.trackList.Delete()
        tracks := MusicControllerPro.playlists[MusicControllerPro.currentPlaylist]
        if (!tracks) {
            return
        }
        for index, track in tracks {
            status := (index - 1 = MusicControllerPro.currentTrackIndex && MusicControllerPro.isPlaying) ? "Play" : "Ready"
            MusicControllerPro.trackList.Add("", index, track.title, track.duration, status)
            MusicControllerPro.trackList.SetRowData(MusicControllerPro.trackList.GetCount(), index - 1)
        }
        MusicControllerPro.UpdateNowPlaying()
    }

    static PlaySelected(*) {
        row := MusicControllerPro.trackList.GetNext()
        if (!row) {
            return
        }
        index := MusicControllerPro.trackList.GetRowData(row)
        MusicControllerPro.StartPlayback(index)
    }

    static StartPlayback(trackIndex := -1) {
        tracks := MusicControllerPro.playlists[MusicControllerPro.currentPlaylist]
        if (!tracks || tracks.Length = 0) {
            MusicControllerPro.UpdateStatus("No tracks available in this playlist.")
            return
        }
        if (trackIndex >= 0) {
            MusicControllerPro.currentTrackIndex := trackIndex
        } else if (MusicControllerPro.currentTrackIndex = -1) {
            MusicControllerPro.currentTrackIndex := 0
        }
        if (MusicControllerPro.currentTrackIndex >= tracks.Length) {
            MusicControllerPro.currentTrackIndex := 0
        }
        MusicControllerPro.isPlaying := true
        MusicControllerPro.progressBar.Value := 0
        MusicControllerPro.EnsureProgressTimer()
        MusicControllerPro.AppendLog("Playing track " . tracks[MusicControllerPro.currentTrackIndex + 1].title)
        MusicControllerPro.UpdateTrackList()
        MusicControllerPro.UpdateStatus("Playing " . tracks[MusicControllerPro.currentTrackIndex + 1].title)
    }

    static TogglePlayback(*) {
        if (!MusicControllerPro.isPlaying) {
            MusicControllerPro.StartPlayback()
        } else {
            MusicControllerPro.isPlaying := false
            MusicControllerPro.AppendLog("Playback paused.")
            MusicControllerPro.UpdateNowPlaying()
            MusicControllerPro.UpdateStatus("Playback paused.")
        }
    }

    static StopPlayback(*) {
        MusicControllerPro.isPlaying := false
        MusicControllerPro.currentTrackIndex := -1
        MusicControllerPro.progressBar.Value := 0
        MusicControllerPro.StopProgressTimer()
        MusicControllerPro.UpdateTrackList()
        MusicControllerPro.UpdateStatus("Playback stopped.")
        MusicControllerPro.AppendLog("Playback stopped.")
    }

    static PreviousTrack(*) {
        tracks := MusicControllerPro.playlists[MusicControllerPro.currentPlaylist]
        if (!tracks || tracks.Length = 0) {
            return
        }
        if (MusicControllerPro.currentTrackIndex <= 0) {
            MusicControllerPro.currentTrackIndex := tracks.Length - 1
        } else {
            MusicControllerPro.currentTrackIndex--
        }
        MusicControllerPro.StartPlayback(MusicControllerPro.currentTrackIndex)
    }

    static NextTrack(*) {
        tracks := MusicControllerPro.playlists[MusicControllerPro.currentPlaylist]
        if (!tracks || tracks.Length = 0) {
            return
        }
        MusicControllerPro.currentTrackIndex++
        if (MusicControllerPro.currentTrackIndex >= tracks.Length) {
            MusicControllerPro.currentTrackIndex := MusicControllerPro.repeatEnabled ? 0 : tracks.Length - 1
            if (!MusicControllerPro.repeatEnabled) {
                MusicControllerPro.StopPlayback()
                return
            }
        }
        MusicControllerPro.StartPlayback(MusicControllerPro.currentTrackIndex)
    }

    static PlayRandom(*) {
        tracks := MusicControllerPro.playlists[MusicControllerPro.currentPlaylist]
        if (!tracks || tracks.Length = 0) {
            return
        }
        MusicControllerPro.currentTrackIndex := Random(0, tracks.Length - 1)
        MusicControllerPro.StartPlayback(MusicControllerPro.currentTrackIndex)
    }

    static HandleVolumeChange(*) {
        MusicControllerPro.volume := MusicControllerPro.volumeSlider.Value
        MusicControllerPro.volumeLabel.Text := MusicControllerPro.volume . "%"
        MusicControllerPro.UpdateStatus("Volume: " . MusicControllerPro.volume . "%")
    }

    static AdjustVolume(delta) {
        newValue := MusicControllerPro.volume + delta
        if (newValue < 0) {
            newValue := 0
        } else if (newValue > 100) {
            newValue := 100
        }
        MusicControllerPro.volume := newValue
        if (MusicControllerPro.volumeSlider) {
            MusicControllerPro.volumeSlider.Value := newValue
        }
        if (MusicControllerPro.volumeLabel) {
            MusicControllerPro.volumeLabel.Text := newValue . "%"
        }
        MusicControllerPro.UpdateStatus("Volume: " . newValue . "%")
    }

    static ToggleRepeat() {
        MusicControllerPro.repeatEnabled := !MusicControllerPro.repeatEnabled
        MusicControllerPro.UpdateStatus("Repeat " . (MusicControllerPro.repeatEnabled ? "enabled" : "disabled"))
        MusicControllerPro.AppendLog("Repeat toggled: " . (MusicControllerPro.repeatEnabled ? "on" : "off"))
    }

    static UpdateNowPlaying() {
        tracks := MusicControllerPro.playlists[MusicControllerPro.currentPlaylist]
        if (!tracks || MusicControllerPro.currentTrackIndex < 0 || MusicControllerPro.currentTrackIndex >= tracks.Length) {
            MusicControllerPro.currentTrackInfo.Text := "Nothing playing"
            return
        }
        track := tracks[MusicControllerPro.currentTrackIndex + 1]
        status := MusicControllerPro.isPlaying ? "Playing" : "Paused"
        MusicControllerPro.currentTrackInfo.Text := status . " – " . track.title . " (" . track.duration . ")"
    }

    static EnsureProgressTimer() {
        if (MusicControllerPro.timerRef) {
            return
        }
        MusicControllerPro.timerRef := ObjBindMethod(MusicControllerPro, "AdvanceProgress")
        SetTimer(MusicControllerPro.timerRef, 500)
    }

    static StopProgressTimer() {
        if (MusicControllerPro.timerRef) {
            SetTimer(MusicControllerPro.timerRef, 0)
            MusicControllerPro.timerRef := ""
        }
    }

    static AdvanceProgress(*) {
        if (!MusicControllerPro.isPlaying) {
            return
        }
        bar := MusicControllerPro.progressBar
        newValue := bar.Value + 2
        if (newValue >= 100) {
            bar.Value := 0
            MusicControllerPro.NextTrack()
        } else {
            bar.Value := newValue
        }
    }

    static CreatePlaylistDialog(*) {
        name := InputBox("Enter new playlist name:", "Create Playlist")
        if (!name || MusicControllerPro.playlists.Has(name)) {
            return
        }
        MusicControllerPro.AddPlaylist(name, [])
        MusicControllerPro.playlistCombo.Add(name)
        MusicControllerPro.playlistCombo.Text := name
        MusicControllerPro.currentPlaylist := name
        MusicControllerPro.UpdateTrackList()
        MusicControllerPro.AppendLog("Created playlist " . name)
    }
}

; Register exit handler
OnExit((*) => MusicControllerPro.HideGui())

MusicControllerPro.Init()