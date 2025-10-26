#NoEnv
#SingleInstance Force
#Persistent
#SingleInstance ignore
SetWorkingDir %A_ScriptDir%
SetBatchLines -1

; Configuration
updateInterval := 1000  ; Update every second

; Create the GUI
Gui( +AlwaysOnTop +Resize +ToolWindow
Gui( Font, s10, Consolas

; CPU Usage
Gui( Add, Text, x10 y10 w100 h20, CPU Usage:
Gui( Add, Progress, x120 y10 w200 h20 vCPUProgress BackgroundEEEEEE
Gui( Add, Text, x330 y10 w40 h20 vCPUPercent, 0`%

; Memory Usage
Gui( Add, Text, x10 y40 w100 h20, Memory Usage:
Gui( Add, Progress, x120 y40 w200 h20 vMemProgress BackgroundEEEEEE
Gui( Add, Text, x330 y40 w80 h20 vMemPercent, 0`%

; Disk Usage
Gui( Add, Text, x10 y70 w100 h20, C:\ Usage:
Gui( Add, Progress, x120 y70 w200 h20 vDiskProgress BackgroundEEEEEE
Gui( Add, Text, x330 y70 w80 h20 vDiskPercent, 0`%

; Network
Gui( Add, Text, x10 y100 w100 h20, Network:
Gui( Add, Text, x120 y100 w300 h20 vNetworkInfo, Download: 0 KB/s  Upload: 0 KB/s

; Process List
Gui( Add, Text, x10 y130 w100 h20, Top Processes:
Gui( Add, ListView, x10 y150 w400 h200 vProcessList, Process|CPU`%|Memory (MB)
LV_ModifyCol(1, 200)
LV_ModifyCol(2, 80)
LV_ModifyCol(3, 80)

; System Info
Gui( Add, Text, x10 y360 w400 h20 vSystemInfo, 

; Buttons
Gui( Add, Button, x10 y390 w100 h30 vRefreshBtn gRefresh, &Refresh
Gui( Add, Button, x120 y390 w100 h30 vExitBtn gExitApp, E&xit

; Initial update
GoSub, UpdateSystemInfo
SetTimer, UpdateSystemInfo, %updateInterval%

; Show the GUI
Gui( Show, w430 h430, System Monitor
return

UpdateSystemInfo:
    ; Get CPU usage
    static lastIdle, lastKernel, lastUser
    static lastNetIn, lastNetOut, lastNetTime
    
    ; CPU Usage
    if (A_TimeIdlePhysical != "" && lastIdle != "") {
        idleTime := A_TimeIdlePhysical - lastIdle
        totalTime := (A_TimeSincePriorIdle - lastKernel - lastUser) / 1000  ; Convert to seconds
        cpuUsage := 100 - (idleTime / totalTime * 100)
        cpuUsage := Round(cpuUsage, 1)
        GuiControl,, CPUProgress, %cpuUsage%
        GuiControl,, CPUPercent, %cpuUsage%`%
    }
    
    ; Memory Usage
    MEMORYSTATUSEX(mem)
    memUsage := 100 - mem.MemoryLoad
    usedMemGB := Round((mem.TotalPhys - mem.AvailPhys) / 1024 / 1024 / 1024, 2)
    totalMemGB := Round(mem.TotalPhys / 1024 / 1024 / 1024, 2)
    GuiControl,, MemProgress, %memUsage%
    GuiControl,, MemPercent, %usedMemGB% / %totalMemGB% GB
    
    ; Disk Usage
    DriveSpace, freeSpace, C:\, free
    DriveSpace, totalSpace, C:\
    diskUsage := 100 - (freeSpace / totalSpace * 100)
    diskUsage := Round(diskUsage, 1)
    GuiControl,, DiskProgress, %diskUsage%
    GuiControl,, DiskPercent, %diskUsage%`%
    
    ; Network Usage
    static lastNetIn := 0, lastNetOut := 0
    currentNetIn := GetNetInOut("in")
    currentNetOut := GetNetInOut("out")
    
    ; Calculate bytes per second
    elapsed := (A_TickCount - lastNetTime) / 1000  ; in seconds
    if (elapsed > 0) {
        dlSpeed := (currentNetIn - lastNetIn) / elapsed
        ulSpeed := (currentNetOut - lastNetOut) / elapsed
        
        ; Convert to KB/s
        dlSpeedKB := Round(dlSpeed / 1024, 1)
        ulSpeedKB := Round(ulSpeed / 1024, 1)
        
        GuiControl,, NetworkInfo, Download: %dlSpeedKB% KB/s  Upload: %ulSpeedKB% KB/s
    }
    
    lastNetIn := currentNetIn
    lastNetOut := currentNetOut
    lastNetTime := A_TickCount
    
    ; Update process list
    UpdateProcessList()
    
    ; Update system info
    FormatTime, timeNow,, HH:mm:ss
    GuiControl,, SystemInfo, Last updated: %timeNow%  |  CPU: %A_CPUName%  |  OS: %A_OSVersion%
    
    ; Update last values for next iteration
    lastIdle := A_TimeIdlePhysical
    lastKernel := A_TimeSincePriorIdle
    lastUser := A_TimeSincePriorInterrupt
return

UpdateProcessList() {
    global
    
    ; Clear the list
    LV_Delete()
    
    ; Get process list using WMI
    wmi := ComObjGet("winmgmts:")
    queryStr := "Select Name, PercentProcessorTime, WorkingSetSize from Win32_PerfFormattedData_PerfProc_Process where Name != '_Total' and Name != 'Idle'"
    processes := wmi.ExecQuery(queryStr)
    
    ; Create array to sort processes
    procArray := []
    
    for process in processes {
        procName := process.Name
        cpuUsage := process.PercentProcessorTime
        memUsage := Round(process.WorkingSetSize / 1024 / 1024, 1)  ; Convert to MB
        
        ; Skip processes with 0 CPU usage and minimal memory
        if (cpuUsage = 0 && memUsage < 1) {
            continue
        }
        
        procArray.Push({name: procName, cpu: cpuUsage, mem: memUsage})
    }
    
    ; Sort by CPU usage (descending)
    sortedArray := []
    for i, proc in procArray {
        inserted := false
        for j, sortedProc in sortedArray {
            if (proc.cpu > sortedProc.cpu) {
                sortedArray.InsertAt(j, proc)
                inserted := true
                break
            }
        }
        if (!inserted) {
            sortedArray.Push(proc)
        }
    }
    
    ; Add top 10 processes to the list
    loop % (sortedArray.Length() > 10 ? 10 : sortedArray.Length()) {
        proc := sortedArray[A_Index]
        LV_Add("", proc.name, proc.cpu "%", proc.mem " MB")
    }
    
    ; Auto-size columns
    LV_ModifyCol()
}

GetNetInOut(direction) {
    static lastIn, lastOut, lastTime
    
    ; Get network statistics using WMI
    wmi := ComObjGet("winmgmts:")
    queryStr := "Select BytesReceivedPersec, BytesSentPersec from Win32_PerfFormattedData_Tcpip_IPv4"
    netStats := wmi.ExecQuery(queryStr)
    
    ; Get current values
    for stat in netStats {
        bytesIn := stat.BytesReceivedPersec
        bytesOut := stat.BytesSentPersec
        break
    }
    
    return (direction = "in") ? bytesIn : bytesOut
}

MEMORYSTATUSEX(ByRef mem) {
    static MEMORYSTATUSEX, init := VarSetCapacity(MEMORYSTATUSEX, 64, 0) && NumPut(64, MEMORYSTATUSEX, "UInt")
    if !(DllCall("kernel32.dll\GlobalMemoryStatusEx", "Ptr", &MEMORYSTATUSEX))
        return false
    
    mem := {}
    mem.MemoryLoad := NumGet(&MEMORYSTATUSEX + 4, "UInt")
    mem.TotalPhys := NumGet(&MEMORYSTATUSEX + 8, "UInt64")
    mem.AvailPhys := NumGet(&MEMORYSTATUSEX + 16, "UInt64")
    mem.TotalPageFile := NumGet(&MEMORYSTATUSEX + 24, "UInt64")
    mem.AvailPageFile := NumGet(&MEMORYSTATUSEX + 32, "UInt64")
    mem.TotalVirtual := NumGet(&MEMORYSTATUSEX + 40, "UInt64")
    mem.AvailVirtual := NumGet(&MEMORYSTATUSEX + 48, "UInt64")
    
    return true
}

Refresh:
    GoSub, UpdateSystemInfo
return

GuiClose:
ExitApp

^!S::  ; Ctrl+Alt+S to show/hide
    if (WinExist("System Monitor")) {
        if (WinActive("System Monitor")) {
            WinHide, System Monitor
        } else {
            WinShow, System Monitor
            WinActivate, System Monitor
        }
    }
return
