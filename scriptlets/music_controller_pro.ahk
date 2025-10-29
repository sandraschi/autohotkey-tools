; ==============================================================================
; Music Controller Pro
; @name: Music Controller Pro
; @version: 1.0.0
; @description: Advanced music control with playlist management and visualizer
; @category: media
; @author: Sandra
; @hotkeys: #Space, #Left, #Right, #Up, #Down, #M
; @enabled: true
; ==============================================================================

#Requires AutoHotkey v2.0+
#SingleInstance Force


; Suppress error popups - log to file instead
OnError(LogError)

LogError(Thrown, Mode) {
    FileAppend("Error: " . Thrown.Message . " at line " . Thrown.Line . "
", "errors.log", "UTF-8")`n        OutputDebug(errorMsg)  ; Enable LLM debugging
    return 1  ; Suppress popup (1 = suppress, 0 = show)
}


class MusicController {
    static playlists := Map()
    static currentPlaylist := ""
    static currentTrack := 0
    static isPlaying := false
    static volume := 50
    
    static Init() {
        this.LoadPlaylists()
        this.CreateGUI()
        this.SetupHotkeys()
    }
    
    static LoadPlaylists() {
        ; Default playlists
        this.playlists["Chill"] := ["Lofi Hip Hop", "Ambient Sounds", "Jazz", "Acoustic"]
        this.playlists["Workout"] := ["Electronic", "Rock", "Pop", "Hip Hop"]
        this.playlists["Focus"] := ["Classical", "Instrumental", "Nature Sounds", "White Noise"]
        this.playlists["Party"] := ["Dance", "House", "Techno", "EDM"]
        
        this.currentPlaylist := "Chill"
    }
    
    static CreateGUI() {
        this.gui := Gui("+Resize", "Music Controller Pro")
        
        ; Title
        this.gui.Add("Text", "w500 h30 Center", "ðŸŽµ Music Controller Pro")
        
        ; Playlist selector
        playlistPanel := this.gui.Add("Text", "w500 h40")
        this.gui.Add("Text", "x10 y10 w80 h20", "Playlist:")
        this.playlistCombo := this.gui.Add("DropDownList", "x100 y8 w150", Array.from(this.playlists.Keys))
        this.playlistCombo.Text := this.currentPlaylist
        this.playlistCombo.OnEvent("Change", this.PlaylistChanged.Bind(this))
        
        newPlaylistBtn := this.gui.Add("Button", "x260 y8 w80 h25", "New")
        newPlaylistBtn.OnEvent("Click", this.CreatePlaylist.Bind(this))
        
        ; Track list
        this.gui.Add("Text", "w500 h20", "Tracks:")
        this.trackList := this.gui.Add("ListView", "w500 h150", ["#", "Track", "Duration", "Status"])
        this.trackList.OnEvent("DoubleClick", this.PlayTrack.Bind(this))
        
        ; Control panel
        controlPanel := this.gui.Add("Text", "w500 h80")
        
        prevBtn := this.gui.Add("Button", "x10 y10 w60 h40", "â®")
        playBtn := this.gui.Add("Button", "x80 y10 w60 h40", "â–¶")
        pauseBtn := this.gui.Add("Button", "x150 y10 w60 h40", "â¸")
        nextBtn := this.gui.Add("Button", "x220 y10 w60 h40", "â­")
        stopBtn := this.gui.Add("Button", "x290 y10 w60 h40", "â¹")
        
        prevBtn.OnEvent("Click", this.PreviousTrack.Bind(this))
        playBtn.OnEvent("Click", this.PlayTrack.Bind(this))
        pauseBtn.OnEvent("Click", this.PauseTrack.Bind(this))
        nextBtn.OnEvent("Click", this.NextTrack.Bind(this))
        stopBtn.OnEvent("Click", this.StopTrack.Bind(this))
        
        ; Volume control
        this.gui.Add("Text", "x10 y60 w60 h20", "Volume:")
        this.volumeSlider := this.gui.Add("Slider", "x80 y58 w200 h25 Range0-100", this.volume)
        this.volumeSlider.OnEvent("Change", this.VolumeChanged.Bind(this))
        this.volumeLabel := this.gui.Add("Text", "x290 y60 w40 h20", this.volume . "%")
        
        ; Progress bar
        this.gui.Add("Text", "w500 h20", "Progress:")
        this.progressBar := this.gui.Add("Progress", "w500 h20", 0)
        
        ; Current track info
        this.gui.Add("Text", "w500 h20", "Now Playing:")
        this.currentTrackInfo := this.gui.Add("Text", "w500 h40", "No track selected")
        
        ; Visualizer
        this.gui.Add("Text", "w500 h20", "Visualizer:")
        this.visualizer := this.gui.Add("Text", "w500 h100 BackgroundBlack", "")
        
        ; Action buttons
        actionPanel := this.gui.Add("Text", "w500 h40")
        
        shuffleBtn := this.gui.Add("Button", "x10 y10 w80 h25", "Shuffle")
        repeatBtn := this.gui.Add("Button", "x100 y10 w80 h25", "Repeat")
        randomBtn := this.gui.Add("Button", "x190 y10 w80 h25", "Random")
        settingsBtn := this.gui.Add("Button", "x280 y10 w80 h25", "Settings")
        
        shuffleBtn.OnEvent("Click", this.ShufflePlaylist.Bind(this))
        repeatBtn.OnEvent("Click", this.ToggleRepeat.Bind(this))
        randomBtn.OnEvent("Click", this.PlayRandom.Bind(this))
        settingsBtn.OnEvent("Click", this.ShowSettings.Bind(this))
        
        this.gui.Show("w520 h450")
        this.UpdateTrackList()
        this.StartVisualizer()
    }
    
    static PlaylistChanged(*) {
        this.currentPlaylist := this.playlistCombo.Text
        this.currentTrack := 0
        this.UpdateTrackList()
    }
    
    static UpdateTrackList() {
        this.trackList.Delete()
        
        if (this.playlists.Has(this.currentPlaylist)) {
            tracks := this.playlists[this.currentPlaylist]
            for i, track in tracks {
                status := (i = this.currentTrack + 1) ? "Playing" : "Ready"
                this.trackList.Add("", i, track, "3:45", status)
            }
        }
    }
    
    static PlayTrack(*) {
        selected := this.trackList.GetNext()
        if (selected > 0) {
            this.currentTrack := selected - 1
            this.isPlaying := true
            this.UpdateTrackList()
            this.UpdateCurrentTrackInfo()
            this.SimulatePlayback()
        }
    }
    
    static PauseTrack(*) {
        this.isPlaying := !this.isPlaying
        this.UpdateCurrentTrackInfo()
    }
    
    static StopTrack(*) {
        this.isPlaying := false
        this.currentTrack := 0
        this.UpdateTrackList()
        this.UpdateCurrentTrackInfo()
        this.progressBar.Value := 0
    }
    
    static PreviousTrack(*) {
        if (this.currentTrack > 0) {
            this.currentTrack--
            this.UpdateTrackList()
            this.UpdateCurrentTrackInfo()
        }
    }
    
    static NextTrack(*) {
        tracks := this.playlists[this.currentPlaylist]
        if (this.currentTrack < tracks.Length - 1) {
            this.currentTrack++
            this.UpdateTrackList()
            this.UpdateCurrentTrackInfo()
        }
    }
    
    static VolumeChanged(*) {
        this.volume := this.volumeSlider.Value
        this.volumeLabel.Text := this.volume . "%"
        
        ; Simulate volume change
        ToolTip("Volume: " . this.volume . "%")
        SetTimer(() => ToolTip(), -1000)
    }
    
    static UpdateCurrentTrackInfo() {
        if (this.currentPlaylist && this.playlists.Has(this.currentPlaylist)) {
            tracks := this.playlists[this.currentPlaylist]
            if (this.currentTrack < tracks.Length) {
                track := tracks[this.currentTrack + 1]
                status := this.isPlaying ? "â–¶ Playing" : "â¸ Paused"
                this.currentTrackInfo.Text := status . " - " . track
            }
        }
    }
    
    static SimulatePlayback() {
        if (this.isPlaying) {
            progress := 0
            SetTimer(() => {
                if (this.isPlaying) {
                    progress += 2
                    this.progressBar.Value := progress
                    
                    if (progress >= 100) {
                        this.NextTrack()
                        progress := 0
                    }
                }
            }, 100)
        }
    }
    
    static StartVisualizer() {
        SetTimer(() => {
            if (this.isPlaying) {
                ; Simple visualizer animation
                bars := ""
                Loop 20 {
                    height := Random(10, 100)
                    bars .= "â–ˆ"
                }
                this.visualizer.Text := bars
            } else {
                this.visualizer.Text := ""
            }
        }, 100)
    }
    
    static ShufflePlaylist(*) {
        if (this.playlists.Has(this.currentPlaylist)) {
            tracks := this.playlists[this.currentPlaylist]
            
            ; Fisher-Yates shuffle
            for i := tracks.Length to 2 {
                j := Random(1, i)
                temp := tracks[i]
                tracks[i] := tracks[j]
                tracks[j] := temp
            }
            
            this.playlists[this.currentPlaylist] := tracks
            this.UpdateTrackList()
            ToolTip("Playlist shuffled!")
            SetTimer(() => ToolTip(), -2000)
        }
    }
    
    static ToggleRepeat(*) {
        ToolTip("Repeat mode toggled!")
        SetTimer(() => ToolTip(), -2000)
    }
    
    static PlayRandom(*) {
        if (this.playlists.Has(this.currentPlaylist)) {
            tracks := this.playlists[this.currentPlaylist]
            this.currentTrack := Random(0, tracks.Length - 1)
            this.UpdateTrackList()
            this.UpdateCurrentTrackInfo()
            this.isPlaying := true
            this.SimulatePlayback()
        }
    }
    
    static CreatePlaylist(*) {
        playlistName := InputBox("Enter playlist name:", "New Playlist")
        if (playlistName != "") {
            this.playlists[playlistName] := []
            this.playlistCombo.Add(playlistName)
            this.playlistCombo.Text := playlistName
            this.currentPlaylist := playlistName
            this.UpdateTrackList()
        }
    }
    
    static ShowSettings(*) {
        settingsGui := Gui("+Resize", "Music Settings")
        
        settingsGui.Add("Text", "w300 h20", "Music Settings")
        
        ; Audio device selection
        settingsGui.Add("Text", "x10 y30 w100 h20", "Audio Device:")
        deviceCombo := settingsGui.Add("DropDownList", "x120 y28 w150", ["Default", "Speakers", "Headphones"])
        
        ; Equalizer
        settingsGui.Add("Text", "x10 y60 w100 h20", "Equalizer:")
        bassSlider := settingsGui.Add("Slider", "x120 y58 w150 h25 Range-10-10", 0)
        trebleSlider := settingsGui.Add("Slider", "x280 y58 w150 h25 Range-10-10", 0)
        
        settingsGui.Add("Text", "x120 y85 w80 h20", "Bass")
        settingsGui.Add("Text", "x280 y85 w80 h20", "Treble")
        
        ; Crossfade
        settingsGui.Add("Text", "x10 y110 w100 h20", "Crossfade:")
        crossfadeSlider := settingsGui.Add("Slider", "x120 y108 w200 h25 Range0-10", 0)
        
        ; Save button
        saveBtn := settingsGui.Add("Button", "x10 y140 w80 h25", "Save")
        saveBtn.OnEvent("Click", (*) => {
            settingsGui.Close()
            ToolTip("Settings saved!")
            SetTimer(() => ToolTip(), -2000)
        })
        
        settingsGui.Show("w450 h180")
    }
    
    static SetupHotkeys() {
        ; Global hotkeys for music control
        ; These would be set up to work system-wide
    }
}

; Hotkeys
#Hotkey("Space", (*) => MusicController.PlayTrack()
#Hotkey("Left", (*) => MusicController.PreviousTrack()
#Hotkey("Right", (*) => MusicController.NextTrack()
#Hotkey("Up", (*) => MusicController.VolumeChanged()
#Hotkey("Down", (*) => MusicController.VolumeChanged()
#Hotkey("M", (*) => MusicController.Init()

; Initialize
MusicController.Init()

