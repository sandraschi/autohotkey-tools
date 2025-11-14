# V1 to V2 Conversion TODO

## Status: IN PROGRESS

### Files Requiring Full V1→V2 Rewrite

1. **fun_animations.ahk** - Mixed v1/v2 syntax
   - Issues: GuiControl,, commands
   - Issues: SetTimer, with labels
   - Action: Needs complete rewrite to v2

2. **annoying_sounds.ahk** - Mixed v1/v2 syntax
   - Issues: GuiControl,, commands  
   - Issues: SetTimer, with labels
   - Action: Needs complete rewrite to v2

3. **dev_context_music_backup.ahk** - Pure v1 with v2 header
   - Issues: Menu, commands
   - Issues: Label handlers
   - Issues: GuiControl, commands
   - Action: Needs complete rewrite to v2

4. **volume_control.ahk** - FIXED ✅
   - Fixed: Progress command → ToolTip()
   - Fixed: SoundGet syntax
   - Status: Now v2 compliant

### Files Already v2 Compliant

✅ mcp_config_manager.ahk - FIXED
✅ PuzzleGame.ahk - FIXED  
✅ ScriptletLauncher.ahk - FIXED (complete rewrite)
✅ quick_notes.ahk - FIXED (SetTimer syntax)
✅ smart_assistant_pro.ahk - FIXED
✅ music_controller_pro.ahk - FIXED
✅ All other 54 scripts - Have OnError handlers

## Conversion Patterns Needed

### GuiControl → Control Property Access
```
v1: GuiControl,, ControlName, NewValue
v2: controlName.Text := "NewValue"
```

### SetTimer with Label → Arrow Function
```
v1: SetTimer, UpdateLabel, 1000
v2: SetTimer(() => UpdateFunction(), 1000)
```

### Menu Commands → A_TrayMenu
```
v1: Menu, Tray, Add, Item, Label
v2: A_TrayMenu.Add("Item", (*) => Function())
```

## Next Steps

1. Convert fun_animations.ahk to v2
2. Convert annoying_sounds.ahk to v2
3. Convert dev_context_music_backup.ahk to v2
4. Test all converted scripts
5. Update documentation












