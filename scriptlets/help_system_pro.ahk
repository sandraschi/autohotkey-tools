; ==============================================================================
; Help System Pro
; @name: Help System Pro
; @version: 1.0.0
; @description: Comprehensive help system explaining AutoHotkey, the bridge, UI, and all features
; @category: utilities
; @author: Sandra
; @hotkeys: F1, ^!h, ^!?
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


class HelpSystem {
    static currentTopic := "overview"
    static helpData := Map()
    
    static Init() {
        this.LoadHelpData()
        this.CreateGUI()
    }
    
    static LoadHelpData() {
        ; Overview
        this.helpData["overview"] := {
            title: "AutoHotkey Scriptlet Collection - Overview",
            content: "
# 🚀 Welcome to the AutoHotkey Scriptlet Collection!

This repository contains a comprehensive collection of **professional-grade AutoHotkey scriptlets** that transform your Windows experience with powerful automation, productivity tools, and entertainment features.

## 🤔 What is AutoHotkey?

**AutoHotkey** is a powerful scripting language for Windows that allows you to:
- **Automate repetitive tasks** with simple scripts
- **Create custom hotkeys** for any application
- **Build desktop applications** with GUIs
- **Control Windows** programmatically
- **Enhance productivity** with smart automation

Think of it as **'programming for everyone'** - you can create powerful tools without being a professional developer!

## 🏗️ What Makes This Repository Special?

### **Professional Architecture**
- **Plugin System**: Dynamic scriptlet discovery and management
- **Modern Web Interface**: Beautiful HTML5 launcher with themes
- **Configuration Management**: Smart environment detection
- **Testing Framework**: Comprehensive testing infrastructure
- **Error Handling**: Robust error handling throughout

### **Amazing Features**
- **10+ Professional Scriptlets**: From productivity to games
- **Real-time Monitoring**: Live system and application monitoring
- **AI Integration**: Smart assistants and workflow automation
- **Modern UIs**: Beautiful, responsive interfaces
- **Voice Commands**: AI-powered voice recognition

## 🎯 Who Should Use This?

- **Power Users**: Enhance Windows productivity
- **Developers**: Professional development tools
- **Gamers**: Fun games and entertainment
- **Automation Enthusiasts**: Workflow automation
- **Anyone**: Who wants to supercharge their Windows experience

## 🚀 Quick Start

1. **Download AutoHotkey v2.0+** from autohotkey.com
2. **Run the Plugin Loader**: `AutoHotkey64.exe plugin_loader.ahk`
3. **Open Web Interface**: `launcher_enhanced.html`
4. **Explore Scriptlets**: Click and try different tools
5. **Use Hotkeys**: Press the hotkeys listed for each scriptlet

Ready to explore? Use the navigation menu to learn about specific components!
            "
        }
        
        ; AutoHotkey Basics
        this.helpData["autohotkey"] := {
            title: "AutoHotkey Basics - What You Need to Know",
            content: "
# 🔧 AutoHotkey Basics

## What is AutoHotkey?

**AutoHotkey** is a free, open-source scripting language for Windows that lets you:
- Create **hotkeys** (keyboard shortcuts) for any action
- **Automate repetitive tasks** with simple scripts
- **Control applications** programmatically
- **Build desktop apps** with graphical interfaces
- **Enhance Windows** with custom functionality

## 🎯 Why AutoHotkey?

### **Easy to Learn**
- **Simple syntax** - readable and intuitive
- **No compilation** - run scripts directly
- **Rich documentation** - extensive help and examples
- **Active community** - helpful forums and resources

### **Powerful Capabilities**
- **System integration** - control Windows deeply
- **Cross-application** - works with any program
- **Real-time** - instant response to events
- **Extensible** - add functionality with libraries

## 📝 Basic AutoHotkey Concepts

### **Hotkeys**
```autohotkey
#Hotkey("Space", (*) => Run('notepad.exe')  ; Win+Space opens Notepad
Hotkey("^!s", (*) => Send('Hello World')   ; Ctrl+Alt+S types 'Hello World'
```

### **Variables**
```autohotkey
name := 'Sandra'
age := 25
message := 'Hello, ' . name . '!'
```

### **Functions**
```autohotkey
GreetUser(name) {
    return 'Hello, ' . name . '!'
}
```

### **GUI Creation**
```autohotkey
MyGui := Gui('+Resize', 'My Application')
MyGui.Add('Text', 'w200 h30', 'Welcome!')
MyGui.Show('w300 h200')
```

## 🔑 Common Hotkey Symbols

- `#` = Windows key
- `^` = Ctrl key
- `!` = Alt key
- `+` = Shift key
- `*` = Any modifier key
- `~` = Don't block original key

## 📚 Learning Resources

- **Official Documentation**: autohotkey.com/docs
- **Community Forum**: autohotkey.com/boards
- **Script Showcase**: autohotkey.com/boards/forum-9.html
- **Tutorial Videos**: YouTube 'AutoHotkey Tutorial'

## 🎮 Try It Yourself!

1. **Create a new file**: `test.ahk`
2. **Add this code**:
```autohotkey
#Requires AutoHotkey v2.0+
MsgBox('Hello from AutoHotkey!')
```
3. **Run it**: Double-click the file
4. **See the magic**: A message box appears!

AutoHotkey is **that simple** to get started!
            "
        }
        
        ; Bridge System
        this.helpData["bridge"] := {
            title: "COM Bridge System - How It Works",
            content: "
# 🌉 COM Bridge System Explained

## What is the COM Bridge?

The **COM Bridge** is a sophisticated system that connects our **modern web interface** with **AutoHotkey scriptlets**. It's like a translator that allows the beautiful HTML5 launcher to communicate with AutoHotkey scripts.

## 🏗️ Architecture Overview

```
┌─────────────────┐    HTTP     ┌─────────────────┐    COM     ┌─────────────────┐
│   Web Browser   │ ──────────► │  PowerShell     │ ────────► │ AutoHotkey      │
│   (launcher.html)│             │  HTTP Server    │           │ Scriptlets      │
└─────────────────┘             └─────────────────┘           └─────────────────┘
```

## 🔧 How It Works

### **1. HTTP Server (PowerShell)**
- **Port**: Runs on port 8765
- **Protocol**: HTTP REST API
- **CORS**: Enabled for web browser access
- **Endpoints**: `/run/`, `/stop/`, `/status`

### **2. Web Interface**
- **Modern HTML5**: Responsive design with themes
- **JavaScript**: Real-time communication
- **AJAX**: Asynchronous requests to bridge
- **WebSocket**: Live updates (future enhancement)

### **3. AutoHotkey Integration**
- **Process Management**: Start/stop scriptlets
- **Status Monitoring**: Real-time status updates
- **Error Handling**: Graceful error management
- **Logging**: Comprehensive activity logging

## 🚀 Key Components

### **ScriptletCOMBridge.ahk**
- **Main bridge script** that starts the HTTP server
- **Creates helper batch files** for scriptlet execution
- **Manages PowerShell server** lifecycle
- **Provides tray menu** for quick access

### **Helper Scripts**
- **RunScriptlet.bat**: Executes AutoHotkey scriptlets
- **StopScriptlet.bat**: Terminates running scriptlets
- **PowerShell Server**: HTTP API server

### **Web Interface**
- **launcher_enhanced.html**: Modern web launcher
- **Real-time updates**: Live status and statistics
- **Theme switching**: Dark/light mode support
- **Search functionality**: Find scriptlets instantly

## 🔄 Communication Flow

### **Starting a Scriptlet**
1. **User clicks** scriptlet in web interface
2. **JavaScript sends** HTTP request to `/run/scriptlet.ahk`
3. **PowerShell server** receives request
4. **Batch file executes** AutoHotkey scriptlet
5. **Status updates** sent back to web interface

### **Monitoring Status**
1. **Web interface polls** `/status` endpoint
2. **Server checks** running processes
3. **Status information** returned to browser
4. **UI updates** with current state

## 🛠️ Technical Details

### **HTTP Endpoints**
- `GET /status` - Get server status
- `POST /run/{scriptlet}` - Start a scriptlet
- `POST /stop/{scriptlet}` - Stop a scriptlet
- `OPTIONS /*` - CORS preflight requests

### **Error Handling**
- **Graceful degradation** if bridge fails
- **Fallback to native GUI** if web interface unavailable
- **Comprehensive logging** for troubleshooting
- **User-friendly error messages**

### **Security Considerations**
- **Local-only access** (localhost:8765)
- **No external network** exposure
- **Process isolation** between components
- **Safe scriptlet execution** environment

## 🎯 Benefits of This Architecture

### **Modern Web Interface**
- **Responsive design** works on any screen size
- **Beautiful themes** with dark/light mode
- **Real-time updates** without page refresh
- **Search and filtering** capabilities

### **Separation of Concerns**
- **Web UI** handles presentation
- **Bridge** handles communication
- **Scriptlets** handle functionality
- **Easy to maintain** and extend

### **Extensibility**
- **Easy to add** new scriptlets
- **Simple API** for integration
- **Plugin system** for dynamic discovery
- **Future enhancements** possible

## 🔧 Troubleshooting

### **Bridge Not Starting**
- Check if port 8765 is available
- Verify PowerShell execution policy
- Check Windows Firewall settings
- Review error logs in tray menu

### **Web Interface Not Loading**
- Ensure bridge is running (check tray icon)
- Try refreshing the browser page
- Check browser console for errors
- Verify file paths are correct

### **Scriptlets Not Executing**
- Check AutoHotkey installation
- Verify scriptlet file permissions
- Review batch file execution
- Check Windows security settings

The COM Bridge makes our scriptlet collection **modern, accessible, and powerful**!
            "
        }
        
        ; Web Interface
        this.helpData["webui"] := {
            title: "Web Interface - Modern Launcher Explained",
            content: "
# 🌐 Web Interface - Modern Launcher

## What is the Web Interface?

The **Web Interface** is a beautiful, modern HTML5 application that provides a **professional-grade launcher** for all your AutoHotkey scriptlets. It's designed to be intuitive, responsive, and feature-rich.

## 🎨 Design Philosophy

### **Modern & Professional**
- **Clean design** with professional aesthetics
- **Responsive layout** that works on any screen size
- **Smooth animations** and transitions
- **Intuitive navigation** with clear visual hierarchy

### **User-Centric**
- **Easy to use** - no technical knowledge required
- **Fast access** - find and launch scriptlets instantly
- **Visual feedback** - see what's running and what's not
- **Customizable** - themes and settings

## 🚀 Key Features

### **📱 Responsive Design**
- **Mobile-friendly** - works on phones and tablets
- **Desktop optimized** - takes advantage of large screens
- **Adaptive layout** - adjusts to window size
- **Touch support** - works with touch screens

### **🎨 Theme System**
- **Dark Mode** - Easy on the eyes for night use
- **Light Mode** - Clean and bright for day use
- **Auto Theme** - Switches based on system preference
- **Persistent** - Remembers your preference

### **🔍 Search & Discovery**
- **Real-time search** - Find scriptlets as you type
- **Category filtering** - Browse by type
- **Command palette** - Press Ctrl+K for quick actions
- **Smart suggestions** - Intelligent search results

### **📊 Live Statistics**
- **Real-time updates** - See what's running
- **Performance metrics** - System resource usage
- **Activity monitoring** - Track scriptlet usage
- **Status indicators** - Visual status of all components

## 🎮 Interface Components

### **Header**
- **Logo and title** - Clear branding
- **Status indicator** - Shows bridge connection
- **Theme toggle** - Switch between dark/light mode
- **Settings access** - Quick access to preferences

### **Search Bar**
- **Instant search** - Results appear as you type
- **Search suggestions** - Helpful autocomplete
- **Clear button** - Easy to reset search
- **Keyboard shortcuts** - Ctrl+F to focus

### **Category Tabs**
- **All Scriptlets** - See everything at once
- **Utilities** - Productivity and system tools
- **Development** - Coding and development tools
- **Media** - Music, video, and entertainment
- **Games** - Fun games and entertainment
- **Settings** - Configuration and preferences

### **Scriptlet Cards**
- **Visual design** - Beautiful card-based layout
- **Status indicators** - Running/stopped/error states
- **Quick actions** - Click to toggle, right-click for menu
- **Metadata display** - Version, author, description
- **Hotkey display** - See available shortcuts

### **Statistics Dashboard**
- **Total scriptlets** - Count of available tools
- **Running count** - Currently active scriptlets
- **Categories** - Number of different types
- **Uptime** - How long the system has been running

## ⌨️ Keyboard Shortcuts

### **Navigation**
- `Ctrl+K` - Open command palette
- `Tab` - Navigate between elements
- `Enter` - Activate focused element
- `Escape` - Close dialogs and palettes

### **Search**
- `Ctrl+F` - Focus search bar
- `Up/Down` - Navigate search results
- `Enter` - Select highlighted result

### **Actions**
- `Space` - Toggle selected scriptlet
- `R` - Refresh scriptlet list
- `S` - Open settings
- `H` - Show help

## 🎯 Command Palette (Ctrl+K)

The **Command Palette** is a powerful feature that lets you quickly access any function:

### **Available Commands**
- **Toggle [Scriptlet Name]** - Start/stop specific scriptlets
- **Switch to [Category]** - Jump to different categories
- **Open Settings** - Access configuration
- **Toggle Theme** - Switch dark/light mode
- **Show Help** - Open this help system
- **Refresh All** - Reload all scriptlets

### **Usage**
1. **Press Ctrl+K** anywhere in the interface
2. **Type your command** - Search appears instantly
3. **Select with arrow keys** or mouse
4. **Press Enter** to execute

## ⚙️ Settings Panel

### **General Settings**
- **Auto-start enabled scriptlets** - Launch on startup
- **Show notifications** - Desktop notifications
- **Enable global hotkeys** - System-wide shortcuts

### **Display Settings**
- **Theme selection** - Light, Dark, or Auto
- **Font size** - Adjustable text size
- **Animation speed** - Control transition speed
- **Layout density** - Compact or spacious

### **Advanced Settings**
- **Bridge port** - Change HTTP server port
- **Update frequency** - How often to refresh
- **Logging level** - Debug information
- **Cache settings** - Performance optimization

## 🔧 Technical Implementation

### **Technologies Used**
- **HTML5** - Modern web standards
- **CSS3** - Advanced styling and animations
- **JavaScript ES6+** - Modern JavaScript features
- **Fetch API** - Asynchronous communication
- **Local Storage** - Persistent settings

### **Browser Compatibility**
- **Chrome/Edge** - Full support
- **Firefox** - Full support
- **Safari** - Full support
- **Mobile browsers** - Responsive design

### **Performance**
- **Lazy loading** - Scriptlets load on demand
- **Caching** - Smart caching for speed
- **Debounced search** - Efficient search performance
- **Minimal DOM updates** - Smooth animations

## 🎨 Customization

### **Themes**
- **Built-in themes** - Professional light and dark
- **Custom themes** - Easy to create your own
- **Theme persistence** - Remembers your choice
- **System integration** - Follows Windows theme

### **Layout**
- **Responsive grid** - Adapts to screen size
- **Card density** - Adjustable spacing
- **Font scaling** - Accessibility support
- **Animation preferences** - Control motion

The Web Interface makes our scriptlet collection **accessible, beautiful, and powerful** for everyone!
            "
        }
        
        ; Scriptlets Overview
        this.helpData["scriptlets"] := {
            title: "Scriptlets Collection - What's Available",
            content: "
# 🎯 Scriptlets Collection - What's Available

## What are Scriptlets?

**Scriptlets** are self-contained AutoHotkey applications that provide specific functionality. Think of them as **mini-apps** that enhance your Windows experience with powerful automation, productivity tools, and entertainment features.

## 🏆 Our Collection

### **🔧 Productivity Scriptlets**

#### **Smart Clipboard Manager** 🧠
- **Advanced clipboard history** with search and filtering
- **Text formatting** and smart paste options
- **Real-time monitoring** of clipboard changes
- **Hotkeys**: `#v`, `^!c`, `^!v`

#### **Text Transformer Pro** ⚡
- **Case conversion**: UPPERCASE, lowercase, Title Case, camelCase, snake_case, kebab-case
- **Text manipulation**: reverse, sort lines, remove duplicates
- **Encoding tools**: Base64 encode/decode
- **Validation**: JSON formatting and validation
- **Hotkeys**: `^!t`, `^!u`, `^!l`, `^!s`

#### **Window Manager Pro** 🪟
- **8-zone window snapping** (left, right, top, bottom, corners, center)
- **Layout modes**: Grid, cascade, and tile layouts
- **Window history** and management
- **Real-time monitoring** of window changes
- **Hotkeys**: `#Left`, `#Right`, `#Up`, `#Down`, `#Space`, `#Tab`

### **💻 Development Tools**

#### **Code Formatter Pro** 🎨
- **Multi-language support**: JavaScript, Python, JSON, XML, HTML, CSS, SQL, AutoHotkey
- **Syntax highlighting** and beautification
- **Minification** and validation tools
- **Professional GUI** with language selection
- **Hotkeys**: `^!f`, `^!b`, `^!c`

#### **Git Assistant Pro** 🌿
- **Advanced Git workflow** automation
- **Commit templates** and branch management
- **Real-time repository** monitoring
- **Built-in Git commands** and status
- **Hotkeys**: `^!g`, `^!commit`, `^!branch`

### **🎵 Media & Entertainment**

#### **Music Controller Pro** 🎶
- **Advanced music control** with playlist management
- **Real-time visualizer** and progress tracking
- **Volume control** and track management
- **Play modes**: Shuffle, repeat, and random
- **Hotkeys**: `#Space`, `#Left`, `#Right`, `#Up`, `#Down`, `#M`

#### **Mini Games Collection** 🎮
- **Snake Game**: Classic snake with scoring system
- **Tetris**: Block puzzle game with levels
- **Memory Game**: Card matching with timer
- **Pong**: Classic arcade game
- **Breakout**: Brick breaking game
- **Minesweeper**: Logic puzzle game
- **Hotkeys**: `^!g`, `#s`, `#t`, `#m`

### **🤖 AI & Automation**

#### **Smart Assistant Pro** 🧠
- **AI-powered voice commands** and recognition
- **Smart workflows** and automation
- **Context-aware assistance** for different scenarios
- **Work session management** (start/end work, focus mode)
- **Hotkeys**: `^!a`, `#v`, `^!s`

#### **Workflow Automator Pro** ⚡
- **Advanced workflow automation** with triggers
- **Conditional execution** based on system events
- **Real-time monitoring** and management
- **Custom workflow creation** and editing
- **Hotkeys**: `^!w`, `^!r`, `^!t`

### **🖥️ System Utilities**

#### **System Monitor** 📊
- **Real-time system resource** monitoring
- **Performance tracking** and alerts
- **System health dashboard** with metrics
- **Hotkeys**: `^!s`

## 🎯 How to Use Scriptlets

### **Method 1: Web Interface (Recommended)**
1. **Open** `launcher_enhanced.html` in your browser
2. **Browse categories** or search for scriptlets
3. **Click** on any scriptlet card to toggle it
4. **Use hotkeys** for quick access

### **Method 2: Plugin Loader**
1. **Run** `AutoHotkey64.exe plugin_loader.ahk`
2. **Use the GUI** to manage scriptlets
3. **Enable/disable** scriptlets as needed
4. **Access** via tray menu

### **Method 3: Direct Execution**
1. **Navigate** to the `scriptlets/` folder
2. **Double-click** any `.ahk` file
3. **Use hotkeys** for functionality
4. **Close** when done

## 🔧 Scriptlet Features

### **Professional Quality**
- **Modern GUIs** with beautiful interfaces
- **Comprehensive error handling** and logging
- **Real-time updates** and status monitoring
- **Extensive documentation** and help

### **Easy Integration**
- **Hotkey support** for quick access
- **Plugin system** for dynamic loading
- **Configuration options** for customization
- **Cross-application** compatibility

### **Advanced Capabilities**
- **Voice commands** and AI integration
- **Workflow automation** and triggers
- **Real-time monitoring** and alerts
- **Multi-language support** and formatting

## 🎮 Getting Started

### **Try These First**
1. **Smart Clipboard Manager** - `#v` to see clipboard history
2. **Text Transformer Pro** - `^!t` to transform text
3. **Window Manager Pro** - `#Left`/`#Right` to snap windows
4. **Music Controller Pro** - `#Space` to control music
5. **Mini Games Collection** - `^!g` to play games

### **Explore Categories**
- **Utilities** - Productivity and system tools
- **Development** - Coding and development aids
- **Media** - Music, video, and entertainment
- **Games** - Fun games and entertainment
- **AI** - Smart assistants and automation

## 🚀 Advanced Usage

### **Customization**
- **Modify hotkeys** in scriptlet files
- **Adjust settings** in configuration files
- **Create custom workflows** with automation
- **Extend functionality** with additional scripts

### **Integration**
- **Combine scriptlets** for complex workflows
- **Use with other applications** via hotkeys
- **Create custom triggers** for automation
- **Share configurations** with others

Our scriptlet collection provides **professional-grade tools** that transform your Windows experience!
            "
        }
        
        ; Installation Guide
        this.helpData["installation"] := {
            title: "Installation Guide - Getting Started",
            content: "
# 📥 Installation Guide - Getting Started

## Prerequisites

### **AutoHotkey v2.0+**
- **Download**: Visit [autohotkey.com](https://autohotkey.com)
- **Version**: AutoHotkey v2.0 or later (v2.1+ recommended)
- **Installation**: Run the installer with default settings
- **Verification**: Right-click desktop → New → AutoHotkey Script

### **Windows Requirements**
- **OS**: Windows 10/11 (Windows 7/8 may work with limitations)
- **PowerShell**: Version 5.1+ (usually pre-installed)
- **Browser**: Modern browser (Chrome, Edge, Firefox, Safari)
- **Permissions**: Administrator rights for some features

## 🚀 Quick Installation

### **Step 1: Download Repository**
```bash
git clone https://github.com/yourusername/autohotkey-scriptlets.git
cd autohotkey-scriptlets
```

### **Step 2: Install AutoHotkey**
1. **Download** AutoHotkey v2.0+ from autohotkey.com
2. **Run installer** with default settings
3. **Verify installation** by creating a test script

### **Step 3: Start the System**
```bash
# Start the plugin loader
AutoHotkey64.exe plugin_loader.ahk

# Open web interface
start launcher_enhanced.html
```

### **Step 4: Verify Everything Works**
1. **Check tray icon** - PluginLoader should be visible
2. **Open web interface** - Should show scriptlets
3. **Try a hotkey** - `#v` for clipboard manager
4. **Check status** - All components should be green

## 🔧 Detailed Installation

### **Method 1: Complete Setup (Recommended)**

#### **1. Download and Extract**
- **Download** the repository ZIP file
- **Extract** to a folder like `C:\Scriptlets\`
- **Ensure** all files are present

#### **2. Install AutoHotkey**
- **Download** AutoHotkey v2.0+ installer
- **Run** `AutoHotkey_2.1.0_setup.exe`
- **Choose** 'Install for all users' if prompted
- **Verify** installation in Start Menu

#### **3. Configure System**
- **Run** `AutoHotkey64.exe plugin_loader.ahk`
- **Check** tray icon appears
- **Open** `launcher_enhanced.html`
- **Verify** web interface loads

#### **4. Test Installation**
- **Try hotkeys**: `#v`, `^!t`, `#Left`
- **Check scriptlets**: Click cards in web interface
- **Verify bridge**: Status should show 'Connected'

### **Method 2: Manual Setup**

#### **1. Install AutoHotkey**
```bash
# Download and install AutoHotkey v2.0+
# Verify installation
AutoHotkey64.exe --version
```

#### **2. Setup Repository**
```bash
# Clone or download repository
git clone <repository-url>
cd autohotkey-scriptlets

# Make scripts executable (if needed)
# Windows should handle this automatically
```

#### **3. Start Components**
```bash
# Terminal 1: Start COM Bridge
AutoHotkey64.exe ScriptletCOMBridge.ahk

# Terminal 2: Start Plugin Loader
AutoHotkey64.exe plugin_loader.ahk

# Browser: Open Web Interface
start launcher_enhanced.html
```

## ⚙️ Configuration

### **Automatic Configuration**
The system automatically detects and configures:
- **AutoHotkey installation** path
- **Python installation** (if available)
- **Development directories**
- **Claude Desktop** (if installed)
- **Optimal settings** for your system

### **Manual Configuration**
Edit `config.json` to customize:
```json
{
  \"paths\": {
    \"repos_dir\": \"D:\\\\Dev\\\\repos\",
    \"claude_exe\": \"C:\\\\Users\\\\...\\\\claude.exe\",
    \"python_exe\": \"C:\\\\Users\\\\...\\\\python.exe\"
  },
  \"hotkeys\": {
    \"show_help\": \"^+h\",
    \"restart_claude\": \"^!r\"
  },
  \"ui\": {
    \"theme\": \"Light\",
    \"font_size\": 9
  }
}
```

## 🔍 Troubleshooting

### **Common Issues**

#### **AutoHotkey Not Found**
- **Check installation**: Look for AutoHotkey in Start Menu
- **Verify path**: `C:\\Program Files\\AutoHotkey\\AutoHotkey64.exe`
- **Reinstall**: Download latest version from autohotkey.com

#### **Bridge Not Starting**
- **Check port 8765**: Ensure it's not in use
- **PowerShell policy**: Run `Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser`
- **Firewall**: Allow PowerShell through Windows Firewall

#### **Web Interface Not Loading**
- **Check bridge**: Ensure COM Bridge is running (tray icon)
- **Browser compatibility**: Use Chrome, Edge, or Firefox
- **File paths**: Verify `launcher_enhanced.html` exists

#### **Scriptlets Not Executing**
- **File permissions**: Ensure `.ahk` files are readable
- **AutoHotkey association**: `.ahk` files should open with AutoHotkey
- **Antivirus**: Check if antivirus is blocking execution

### **Advanced Troubleshooting**

#### **Check Logs**
- **Plugin Loader**: Check `%TEMP%\\plugin_loader.log`
- **COM Bridge**: Check `bridge.log` in script directory
- **System Events**: Check Windows Event Viewer

#### **Reset Configuration**
```bash
# Delete configuration files
del config.json
del config.ini

# Restart system
# Configuration will be regenerated with defaults
```

#### **Verify Installation**
```bash
# Test AutoHotkey
AutoHotkey64.exe --version

# Test script execution
echo MsgBox('Test') > test.ahk
AutoHotkey64.exe test.ahk
del test.ahk
```

## 🎯 Post-Installation

### **First Steps**
1. **Explore scriptlets** in the web interface
2. **Try hotkeys** for different tools
3. **Customize settings** to your preferences
4. **Create shortcuts** for easy access

### **Recommended Workflow**
1. **Start Plugin Loader** on Windows startup
2. **Use web interface** for daily scriptlet management
3. **Learn hotkeys** for frequently used tools
4. **Customize configuration** as needed

### **Getting Help**
- **Press F1** in any scriptlet for help
- **Use `^!h`** to open this help system
- **Check logs** for error information
- **Visit documentation** for detailed guides

## 🎉 Success!

If everything is working correctly, you should see:
- ✅ **Plugin Loader** running (tray icon)
- ✅ **Web Interface** loading in browser
- ✅ **Scriptlets** appearing in the interface
- ✅ **Hotkeys** working (try `#v`)

**Congratulations!** You now have a powerful AutoHotkey scriptlet collection ready to enhance your Windows experience!
            "
        }
        
        ; FAQ
        this.helpData["faq"] := {
            title: "Frequently Asked Questions",
            content: "
# ❓ Frequently Asked Questions

## 🤔 General Questions

### **Q: What is AutoHotkey?**
**A:** AutoHotkey is a free, open-source scripting language for Windows that lets you automate tasks, create hotkeys, and build desktop applications. It's like programming for everyone - you can create powerful tools without being a professional developer.

### **Q: Is this safe to use?**
**A:** Yes! All scriptlets are open-source and designed with security in mind. They only run locally on your computer and don't send data to external servers. However, always review code before running it.

### **Q: Do I need programming knowledge?**
**A:** No! The scriptlets are ready-to-use applications. You just need to know how to run them and use hotkeys. The web interface makes everything user-friendly.

### **Q: Will this slow down my computer?**
**A:** No, the scriptlets are lightweight and designed for efficiency. They only use resources when active, and most run in the background with minimal impact.

## 🔧 Technical Questions

### **Q: Why do I need AutoHotkey v2.0+?**
**A:** This collection uses modern AutoHotkey v2 syntax and features. Version 1.x is outdated and incompatible. Always use the latest version for best results.

### **Q: What is the COM Bridge?**
**A:** The COM Bridge connects our modern web interface with AutoHotkey scriptlets. It's like a translator that allows the beautiful HTML5 launcher to communicate with AutoHotkey scripts.

### **Q: Can I modify the scriptlets?**
**A:** Absolutely! All code is open-source and well-documented. You can customize hotkeys, modify functionality, or create your own scriptlets based on our examples.

### **Q: How do I add my own scriptlets?**
**A:** Simply add your `.ahk` file to the `scriptlets/` folder with proper metadata comments, and the system will automatically discover and load it.

## 🎮 Usage Questions

### **Q: How do I start using scriptlets?**
**A:** 
1. Run `AutoHotkey64.exe plugin_loader.ahk`
2. Open `launcher_enhanced.html` in your browser
3. Click on scriptlet cards to toggle them
4. Use hotkeys for quick access

### **Q: What are hotkeys and how do I use them?**
**A:** Hotkeys are keyboard shortcuts that trigger scriptlet functions. For example, `#v` (Windows+V) opens the clipboard manager. Press the keys simultaneously to activate.

### **Q: Can I change the hotkeys?**
**A:** Yes! Edit the scriptlet files and modify the hotkey definitions. Look for lines like `#v::` and change them to your preferred combinations.

### **Q: How do I stop a scriptlet?**
**A:** Click the scriptlet card again in the web interface, or close the scriptlet's window. Some scriptlets also have stop hotkeys.

## 🚨 Troubleshooting Questions

### **Q: Nothing happens when I press hotkeys**
**A:** 
- Check if AutoHotkey is running
- Verify the scriptlet is enabled
- Check for hotkey conflicts with other applications
- Try running the scriptlet directly

### **Q: The web interface won't load**
**A:**
- Ensure the COM Bridge is running (check tray icon)
- Try refreshing the browser page
- Check if port 8765 is available
- Verify file paths are correct

### **Q: Scriptlets keep crashing**
**A:**
- Check Windows Event Viewer for errors
- Verify AutoHotkey installation
- Try running scriptlets individually
- Check for antivirus interference

### **Q: I get permission errors**
**A:**
- Run as administrator if needed
- Check file permissions
- Ensure AutoHotkey has necessary privileges
- Verify Windows security settings

## 🎯 Advanced Questions

### **Q: Can I create my own scriptlets?**
**A:** Yes! Study the existing scriptlets for examples, read the AutoHotkey documentation, and start with simple scripts. The plugin system makes it easy to integrate new scriptlets.

### **Q: How do I share scriptlets with others?**
**A:** Share the `.ahk` files and ensure others have AutoHotkey installed. Include the metadata comments so the plugin system can discover them.

### **Q: Can I use this on multiple computers?**
**A:** Yes! Copy the entire repository to other computers and follow the installation guide. Each computer will need AutoHotkey installed.

### **Q: Is there a way to backup my settings?**
**A:** Yes! The `config.json` file contains all your settings. Copy this file to backup your configuration.

## 🎨 Customization Questions

### **Q: Can I change the web interface theme?**
**A:** Yes! Click the theme toggle button (moon icon) in the web interface, or modify the theme settings in the configuration.

### **Q: How do I add new categories?**
**A:** Edit the `metadata.json` file and add new categories to the categories section. Restart the plugin loader to see changes.

### **Q: Can I disable certain scriptlets?**
**A:** Yes! Use the web interface to toggle scriptlets on/off, or edit the `metadata.json` file to set `enabled: false`.

### **Q: How do I update scriptlets?**
**A:** Replace the old `.ahk` files with new versions. The plugin system will automatically detect changes and reload them.

## 🆘 Getting Help

### **Q: Where can I get more help?**
**A:**
- Press `F1` in any scriptlet for context-sensitive help
- Use `^!h` to open this comprehensive help system
- Check the AutoHotkey documentation at autohotkey.com
- Visit the community forums for support

### **Q: How do I report bugs?**
**A:**
- Check the logs first (`%TEMP%\\plugin_loader.log`)
- Note the exact steps to reproduce the issue
- Include your system information (Windows version, AutoHotkey version)
- Create an issue in the repository with detailed information

### **Q: Can I contribute to this project?**
**A:** Absolutely! We welcome contributions. You can:
- Create new scriptlets
- Improve existing ones
- Fix bugs
- Add documentation
- Suggest new features

**Still have questions?** Use `^!h` to open this help system anytime, or press `F1` in any scriptlet for specific help!
            "
        }
    }
    
    static CreateGUI() {
        this.gui := Gui("+Resize +MinSize800x600", "Help System Pro")
        
        ; Menu bar
        this.gui.MenuBar := MenuBar()
        helpMenu := Menu()
        helpMenu.Add("&Overview", this.ShowTopic.Bind(this, "overview"))
        helpMenu.Add("&AutoHotkey Basics", this.ShowTopic.Bind(this, "autohotkey"))
        helpMenu.Add("&Bridge System", this.ShowTopic.Bind(this, "bridge"))
        helpMenu.Add("&Web Interface", this.ShowTopic.Bind(this, "webui"))
        helpMenu.Add("&Scriptlets", this.ShowTopic.Bind(this, "scriptlets"))
        helpMenu.Add("&Installation", this.ShowTopic.Bind(this, "installation"))
        helpMenu.Add("&FAQ", this.ShowTopic.Bind(this, "faq"))
        this.gui.MenuBar.Add("&Help", helpMenu)
        
        ; Toolbar
        toolbar := this.gui.Add("Text", "w800 h40 BackgroundF0F0F0")
        
        ; Navigation buttons
        overviewBtn := this.gui.Add("Button", "x10 y8 w80 h25", "Overview")
        autohotkeyBtn := this.gui.Add("Button", "x100 y8 w100 h25", "AutoHotkey")
        bridgeBtn := this.gui.Add("Button", "x210 y8 w80 h25", "Bridge")
        webuiBtn := this.gui.Add("Button", "x300 y8 w80 h25", "Web UI")
        scriptletsBtn := this.gui.Add("Button", "x390 y8 w80 h25", "Scriptlets")
        installBtn := this.gui.Add("Button", "x480 y8 w80 h25", "Install")
        faqBtn := this.gui.Add("Button", "x570 y8 w60 h25", "FAQ")
        
        overviewBtn.OnEvent("Click", this.ShowTopic.Bind(this, "overview"))
        autohotkeyBtn.OnEvent("Click", this.ShowTopic.Bind(this, "autohotkey"))
        bridgeBtn.OnEvent("Click", this.ShowTopic.Bind(this, "bridge"))
        webuiBtn.OnEvent("Click", this.ShowTopic.Bind(this, "webui"))
        scriptletsBtn.OnEvent("Click", this.ShowTopic.Bind(this, "scriptlets"))
        installBtn.OnEvent("Click", this.ShowTopic.Bind(this, "installation"))
        faqBtn.OnEvent("Click", this.ShowTopic.Bind(this, "faq"))
        
        ; Content area
        this.contentArea := this.gui.Add("Edit", "w800 h500 VScroll HScroll ReadOnly", "")
        
        ; Status bar
        this.statusBar := this.gui.Add("Text", "w800 h20 BackgroundE0E0E0", "Help System Ready - Use navigation buttons or menu to explore topics")
        
        this.gui.Show("w820 h600")
        this.ShowTopic("overview")
    }
    
    static ShowTopic(topic) {
        if (!this.helpData.Has(topic)) {
            this.statusBar.Text := "Topic not found: " . topic
            return
        }
        
        data := this.helpData[topic]
        this.gui.Title := data.title
        this.contentArea.Text := data.content
        this.statusBar.Text := "Showing: " . data.title
        this.currentTopic := topic
    }
}

; Hotkeys
Hotkey("F1", (*) => HelpSystem.Init()
Hotkey("^!h", (*) => HelpSystem.Init()
^!?::HelpSystem.Init()

; Initialize
HelpSystem.Init()


