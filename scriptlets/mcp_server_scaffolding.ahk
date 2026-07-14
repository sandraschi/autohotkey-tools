; ==============================================================================
; MCP Server Scaffolding Tool
; @name: MCP Server Scaffolding Tool
; @version: 1.0.0
; @description: Generate complete MCP server projects with FastMCP 2.12+ patterns. Automated project scaffolding for MCP server development with templates and best practices.
; @description: Features project template generation, FastMCP integration, dependency management, and project structure creation. Supports multiple project types and feature selection.
; @description: Essential development tool for quickly bootstrapping new MCP server projects with proper structure, dependencies, and FastMCP integration patterns.
; @category: development
; @author: Sandra
; @hotkeys: ^!m, F9
; @enabled: true
; @priority: 5
; @tag: mcp, scaffolding, code-generation, templates, fastmcp, development, productivity
; @cli: --create <project_name> - Create new MCP server project
; @cli: --template <type> - Use specific project template
; @cli: --features <list> - Select features to include (basic, advanced, file_ops, web_scraping)
; @cli: --help - Show CLI usage and scaffolding options
; @dependencies: Python, FastMCP
; ==============================================================================

#Requires AutoHotkey v2.0+
#SingleInstance Force
#Include %A_ScriptDir%\lib\ScriptletErrorHandler.ahk

OnError(LogError)

class MCPServerScaffolding {
    static gui := ""
    static nameEdit := ""
    static descriptionEdit := ""
    static locationEdit := ""
    static templateDrop := ""
    static featureChecks := []
    static logEdit := ""
    static statusBar := ""
    static hotkeysRegistered := false
    static projectRoot := A_ScriptDir . "\mcp_projects"
    static logDir := A_ScriptDir . "\logs"
    static logFile := ""
    static logInitialized := false

    static templates := [
        {id: "basic", title: "Basic", description: "Minimal FastMCP server with help/status tools."},
        {id: "file_ops", title: "File Operations", description: "Adds file listing and read helpers."},
        {id: "web", title: "Web", description: "Includes HTTP fetch tool."}
    ]

    static features := [
        {label: "Structured logging"},
        {label: "Configuration stub"},
        {label: "Health check endpoint"},
        {label: "Template README"}
    ]

    static Init() {
        MCPServerScaffolding.EnsureLogging()
        MCPServerScaffolding.AppendLog("Initializing MCP Server Scaffolding tool")
        MCPServerScaffolding.EnsureGui()
        MCPServerScaffolding.SetupHotkeys()
        if (!DirExist(MCPServerScaffolding.projectRoot)) {
            DirCreate(MCPServerScaffolding.projectRoot)
        }
        MCPServerScaffolding.locationEdit.Value := MCPServerScaffolding.projectRoot . "\" . MCPServerScaffolding.Slug("my-mcp-server")
        MCPServerScaffolding.gui.Show("w900 h760 Center")
        if (MCPServerScaffolding.statusBar) {
            MCPServerScaffolding.statusBar.SetText("Ready. Press Ctrl+Alt+M to scaffold a server.")
        }
    }


    static EnsureLogging() {
        if (MCPServerScaffolding.logInitialized) {
            return
        }
        try {
            if (!DirExist(MCPServerScaffolding.logDir)) {
                DirCreate(MCPServerScaffolding.logDir)
            }
        } catch as dirErr {
            OutputDebug("Scaffolding log dir error: " . dirErr.Message)
        }
        MCPServerScaffolding.logFile := MCPServerScaffolding.logDir . "\mcp_server_scaffolding.log"
        MCPServerScaffolding.logInitialized := true
    }

    static AppendLog(message, severity := "INFO") {
        MCPServerScaffolding.EnsureLogging()
        timestamp := FormatTime(A_Now, "yyyy-MM-dd HH:mm:ss")
        entry := "[" . timestamp . "] [" . severity . "] " . message
        try {
            FileAppend(entry . "`n", MCPServerScaffolding.logFile, "UTF-8")
        } catch {
        }
        if (MCPServerScaffolding.logEdit) {
            MCPServerScaffolding.logEdit.Value .= entry . "`n"
            MCPServerScaffolding.logEdit.Redraw()
        }
        OutputDebug(entry)
        if (severity = "ERROR" && MCPServerScaffolding.statusBar) {
            MCPServerScaffolding.statusBar.SetText(message)
        }
    }

    static CreateGui() {
        newGui := Gui("+Resize +MinSize900x680", "MCP Server Scaffolding Tool")
        newGui.BackColor := "1d1d1d"
        newGui.SetFont("s10 cFFFFFF", "Segoe UI")

        newGui.AddText("x20 y20 w860 Center bold", "🚀 MCP Server Scaffolding Tool")
        newGui.AddText("x20 y48 w860 Center cC0C0C0", "Generate FastMCP server skeletons with logging, tools, and documentation.")

        newGui.AddText("x20 y90 w860 Bold", "Project Details")
        newGui.AddText("x20 y118 w140", "Project Name:")
        nameEdit := newGui.AddEdit("x170 y112 w320 h26", "my-mcp-server")
        newGui.AddText("x20 y150 w140", "Description:")
        descriptionEdit := newGui.AddEdit("x170 y144 w520 h26", "Claude MCP server scaffold")
        newGui.AddText("x20 y182 w140", "Location:")
        locationEdit := newGui.AddEdit("x170 y176 w520 h26")
        browseBtn := newGui.AddButton("x700 y176 w180 h26", "Select Directory")
        browseBtn.OnEvent("Click", MCPServerScaffolding.SelectDirectory)

        newGui.AddText("x20 y218 w400 Bold", "Template")
        templateDrop := newGui.AddDropDownList("x20 y244 w320", [])
        for template in MCPServerScaffolding.templates {
            templateDrop.Add(template.title)
        }
        templateDrop.Value := 1
        newGui.AddEdit("x360 y244 w520 h60 ReadOnly -Wrap", MCPServerScaffolding.templates[1].description).BackColor := "262626"

        newGui.AddText("x20 y320 w860 Bold", "Optional Features")
        checks := []
        y := 348
        for index, feature in MCPServerScaffolding.features {
            cb := newGui.AddCheckBox("x20 y" . y . " w300", feature.label)
            cb.Value := 1
            checks.Push(cb)
            if (index = 2) {
                y := 348
                continue
            }
            if (index >= 2) {
                cb.Move(340, y)
            }
            y += 28
        }

        generateBtn := newGui.AddButton("x20 y420 w240 h44", "🚀 Generate Server")
        generateBtn.OnEvent("Click", MCPServerScaffolding.GenerateProject)
        previewBtn := newGui.AddButton("x280 y420 w240 h44", "📂 Preview Layout")
        previewBtn.OnEvent("Click", MCPServerScaffolding.ShowPreview)
        helpBtn := newGui.AddButton("x540 y420 w240 h44", "❓ Help")
        helpBtn.OnEvent("Click", MCPServerScaffolding.ShowHelp)

        newGui.AddText("x20 y480 w860 Bold", "Activity Log")
        logEdit := newGui.AddEdit("x20 y508 w860 h160 ReadOnly VScroll", "")
        logEdit.BackColor := "242424"
        logEdit.SetFont("s9", "Consolas")

        status := newGui.AddStatusBar("Simple")
        status.SetText("Ready")

        newGui.OnEvent("Size", MCPServerScaffolding.OnResize)
        newGui.OnEvent("Close", ObjBindMethod(MCPServerScaffolding, "HideWindow"))
        newGui.OnEvent("Escape", ObjBindMethod(MCPServerScaffolding, "HideWindow"))

        MCPServerScaffolding.gui := newGui
        MCPServerScaffolding.nameEdit := nameEdit
        MCPServerScaffolding.descriptionEdit := descriptionEdit
        MCPServerScaffolding.locationEdit := locationEdit
        MCPServerScaffolding.templateDrop := templateDrop
        MCPServerScaffolding.featureChecks := checks
        MCPServerScaffolding.logEdit := logEdit
        MCPServerScaffolding.statusBar := status
    }

    static SetupHotkeys() {
        if (MCPServerScaffolding.hotkeysRegistered) {
            return
        }
        Hotkey("^!m", MCPServerScaffolding.GenerateProject)
        Hotkey("^F9", MCPServerScaffolding.ShowPreview)
        Hotkey("F9", MCPServerScaffolding.ShowPreview)
        Hotkey("F8", MCPServerScaffolding.HideWindow)
        Hotkey("Escape", (*) => MCPServerScaffolding.gui && WinActive("ahk_id " MCPServerScaffolding.gui.Hwnd) && MCPServerScaffolding.HideWindow())
        MCPServerScaffolding.hotkeysRegistered := true
    }

    static OnResize(gui, minMax, width, height) {
        if (!MCPServerScaffolding.logEdit) {
            return
        }
        MCPServerScaffolding.logEdit.Move(20, height - 180, width - 40, 160)
    }

    static SelectDirectory(*) {
        if (!MCPServerScaffolding.locationEdit) {
            MCPServerScaffolding.AppendLog("Location input not ready; rebuilding GUI.", "WARN")
            MCPServerScaffolding.CreateGui()
        }
        selected := FileSelect("D", MCPServerScaffolding.projectRoot, "Choose project directory")
        if (selected && MCPServerScaffolding.locationEdit) {
            MCPServerScaffolding.locationEdit.Value := selected
            MCPServerScaffolding.AppendLog("Directory selected: " . selected)
        } else {
            MCPServerScaffolding.AppendLog("Directory selection cancelled.", "INFO")
        }
    }

    static ShowPreview(*) {
        name := MCPServerScaffolding.GetProjectName()
        template := MCPServerScaffolding.GetSelectedTemplate()
        preview := "📂 Project Preview`n`n"
        preview .= "Project: " . name . "`n"
        preview .= "Template: " . template.title . "`n"
        preview .= "Description: " . template.description . "`n`n"
        preview .= "Generated structure:`n"
        preview .= "├── main.py`n"
        preview .= "├── src/`n"
        preview .= "│   └── tools/`n"
        preview .= "│       ├── __init__.py`n"
        preview .= "│       ├── standard.py`n"
        preview .= "│       └── custom_" . template.id . ".py`n"
        preview .= "├── config/claude_config.json`n"
        preview .= "├── requirements.txt`n"
        preview .= "├── pyproject.toml`n"
        preview .= "├── README.md`n"
        preview .= "└── .gitignore`n`n"
        preview .= "Selected features:`n"
        for cb in MCPServerScaffolding.featureChecks {
            if (cb.Value) {
                preview .= "• " . cb.Text . "`n"
            }
        }
        MCPServerScaffolding.AppendLog("Preview requested.`n" . preview)
        MCPServerScaffolding.ShowNotification("MCP Scaffolding", "Preview available in log.")
    }

    static GenerateProject(*) {
        name := MCPServerScaffolding.GetProjectName()
        if (name = "") {
            MCPServerScaffolding.AppendLog("Generation aborted: missing project name.", "WARN")
            MCPServerScaffolding.ShowNotification("MCP Scaffolding", "Enter a project name before generating.")
            return
        }
        location := MCPServerScaffolding.locationEdit.Value
        if (location = "") {
            location := MCPServerScaffolding.projectRoot . "\" . MCPServerScaffolding.Slug(name)
            MCPServerScaffolding.locationEdit.Value := location
        }
        template := MCPServerScaffolding.GetSelectedTemplate()
        features := MCPServerScaffolding.GetSelectedFeatures()
        description := MCPServerScaffolding.descriptionEdit.Value

        try {
            MCPServerScaffolding.CreateProjectSkeleton(location)
            MCPServerScaffolding.WriteMainPy(location, name, description, template.id)
            MCPServerScaffolding.WriteTools(location, template.id)
            MCPServerScaffolding.WriteRequirements(location, template.id)
            MCPServerScaffolding.WritePyProject(location, name, description)
            MCPServerScaffolding.WriteConfig(location, name)
            MCPServerScaffolding.WriteReadme(location, name, description, features)
            MCPServerScaffolding.WriteGitignore(location)
            MCPServerScaffolding.AppendLog("Project generated at " . location)
            if (MCPServerScaffolding.statusBar) {
                MCPServerScaffolding.statusBar.SetText("Project generated at " . location)
            }
            MCPServerScaffolding.ShowNotification("MCP Scaffolding", "Project generated at " . location)
            Run('explorer "' . location . '"')
        } catch as e {
            MCPServerScaffolding.AppendLog("Generation error: " . e.Message, "ERROR")
            MCPServerScaffolding.ShowNotification("MCP Scaffolding", "Generation failed. Check log for details.")
        }
    }

    static GetProjectName() {
        return MCPServerScaffolding.Slug(MCPServerScaffolding.nameEdit.Value)
    }

    static GetSelectedTemplate() {
        index := MCPServerScaffolding.templateDrop.Value
        return MCPServerScaffolding.templates[index]
    }

    static GetSelectedFeatures() {
        chosen := []
        for cb in MCPServerScaffolding.featureChecks {
            if (cb.Value) {
                chosen.Push(cb.Text)
            }
        }
        return chosen
    }

    static CreateProjectSkeleton(location) {
        DirCreate(location)
        DirCreate(location . "\src")
        DirCreate(location . "\src\tools")
        DirCreate(location . "\config")
    }

    static WriteMainPy(location, name, description, templateId) {
        path := location . "\main.py"
        content := "#!/usr/bin/env python3`n"
        content .= '"""' . name . " MCP server entrypoint" . '"""' . "`n`n"
        content .= "import logging`n"
        content .= "from fastmcp import FastMCP`n"
        content .= "from src.tools import register_standard_tools, register_custom_tools`n`n"
        content .= "logging.basicConfig(level=logging.INFO, format='%(asctime)s %(levelname)s %(name)s: %(message)s')`n"
        content .= "logger = logging.getLogger(__name__)`n`n"
        content .= "mcp = FastMCP('" . name . "', description='" . description . "')`n"
        content .= "register_standard_tools(mcp)" . "`n"
        content .= "register_custom_tools(mcp)" . "`n`n"
        content .= "if __name__ == '__main__':`n"
        content .= "    logger.info('Starting MCP server " . name . "')`n"
        content .= "    mcp.run()`n"
        MCPServerScaffolding.WriteFile(path, content)
    }

    static WriteTools(location, templateId) {
        base := location . "\src\tools"
        MCPServerScaffolding.WriteFile(base . "\__init__.py", "from .standard import register_standard_tools`nfrom .custom_" . templateId . " import register_custom_tools`n")
        standard := "from fastmcp import FastMCP`n"
        standard .= "from typing import Dict, Any`n"
        standard .= "import datetime`n"
        standard .= "import platform`n"
        standard .= "import sys`n`n"
        standard .= "def register_standard_tools(mcp: FastMCP) -> None:`n"
        standard .= "    @mcp.tool()`n"
        standard .= "    def help() -> Dict[str, Any]:`n"
        standard .= "        '''Describe available tools and their documentation.'''`n"
        standard .= "        tools = []`n"
        standard .= "        for name, func in mcp._tools.items():`n"
        standard .= "            tools.append({`n"
        standard .= "                'name': name,`n"
        standard .= "                'description': func.__doc__ or 'No description provided'`n"
        standard .= "            })`n"
        standard .= "        return {`n"
        standard .= "            'tools': tools,`n"
        standard .= "            'count': len(tools)`n"
        standard .= "        }`n`n"
        standard .= "    @mcp.tool()`n"
        standard .= "    def status() -> Dict[str, Any]:`n"
        standard .= "        now = datetime.datetime.now().isoformat()`n"
        standard .= "        return {`n"
        standard .= "            'status': 'ok',`n"
        standard .= "            'timestamp': now,`n"
        standard .= "            'platform': platform.platform(),`n"
        standard .= "            'python': sys.version`n"
        standard .= "        }`n`n"
        standard .= "    @mcp.tool()`n"
        standard .= "    def ping(message: str = 'pong') -> Dict[str, Any]:`n"
        standard .= "        return {`n"
        standard .= "            'reply': message,`n"
        standard .= "            'time': datetime.datetime.now().isoformat()`n"
        standard .= "        }`n"
        MCPServerScaffolding.WriteFile(base . "\standard.py", standard)

        switch templateId {
            case "basic":
                custom := "def register_custom_tools(mcp):`n"
                custom .= "    @mcp.tool()`n"
                custom .= "    def hello(name: str = 'world') -> str:`n"
                custom .= "        '''Return a friendly greeting.'''`n"
                custom .= "        return f'Hello {name} from MCP!'`n"
            case "file_ops":
                custom := "import os`n`n"
                custom .= "def register_custom_tools(mcp):`n"
                custom .= "    @mcp.tool()`n"
                custom .= "    def list_directory(path: str = '.') -> dict:`n"
                custom .= "        '''List files in the given directory.'''`n"
                custom .= "        try:`n"
                custom .= "            entries = os.listdir(path)`n"
                custom .= "            return {'path': path, 'entries': entries}`n"
                custom .= "        except Exception as exc:`n"
                custom .= "            return {'error': str(exc)}" . "`n"
            case "web":
                custom := "import requests`n`n"
                custom .= "def register_custom_tools(mcp):`n"
                custom .= "    @mcp.tool()`n"
                custom .= "    def fetch(url: str) -> dict:`n"
                custom .= "        '''Fetch text from an HTTP endpoint.'''`n"
                custom .= "        try:`n"
                custom .= "            response = requests.get(url, timeout=10)`n"
                custom .= "            return {'status_code': response.status_code, 'content': response.text[:400]}`n"
                custom .= "        except Exception as exc:`n"
                custom .= "            return {'error': str(exc)}" . "`n"
            default:
                custom := "def register_custom_tools(mcp):`n    pass`n"
        }
        MCPServerScaffolding.WriteFile(base . "\custom_" . templateId . ".py", custom)
    }

    static WriteRequirements(location, templateId) {
        requirements := "fastmcp>=2.12.0`n"
        if (templateId = "web") {
            requirements .= "requests>=2.31.0`n"
        }
        MCPServerScaffolding.WriteFile(location . "\requirements.txt", requirements)
    }

    static WritePyProject(location, name, description) {
        content := "[build-system]`nrequires = ['setuptools>=61.0']`nbuild-backend = 'setuptools.build_meta'`n`n"
        content .= "[project]`nname = '" . name . "'`nversion = '0.1.0'`ndescription = '" . description . "'`nrequires-python = '>=3.10'`n"
        content .= "dependencies = ['fastmcp>=2.12.0']`n"
        MCPServerScaffolding.WriteFile(location . "\pyproject.toml", content)
    }

    static WriteConfig(location, name) {
        escapedName := MCPServerScaffolding.JsonEscape(name)
        escapedLocation := MCPServerScaffolding.JsonEscape(location)
        quote := Chr(34)
        cfg := "{`n"
        cfg .= "  " . quote . "mcpServers" . quote . ": {`n"
        cfg .= "    " . quote . escapedName . quote . ": {`n"
        cfg .= "      " . quote . "command" . quote . ": " . quote . "python" . quote . ",`n"
        cfg .= "      " . quote . "args" . quote . ": [" . quote . "main.py" . quote . "],`n"
        cfg .= "      " . quote . "cwd" . quote . ": " . quote . escapedLocation . quote . "`n"
        cfg .= "    }`n"
        cfg .= "  }`n"
        cfg .= "}`n"
        DirCreate(location . "\config")
        MCPServerScaffolding.WriteFile(location . "\config\claude_config.json", cfg)
    }

    static WriteReadme(location, name, description, features) {
        featureLines := ""
        for feature in features {
            featureLines .= "- " . feature . "`n"
        }
        if (featureLines = "") {
            featureLines := "- Scaffolded FastMCP server structure`n"
        }
        readme := "# " . name . "`n`n" . description . "`n`n"
        readme .= "## Quickstart`n"
        readme .= "``````bash`n"
        readme .= "python -m venv .venv`n"
        readme .= ".venv\\Scripts\\activate`n"
        readme .= "pip install -r requirements.txt`n"
        readme .= "python main.py`n"
        readme .= "``````" . "`n`n"
        readme .= "## Features Included`n" . featureLines
        MCPServerScaffolding.WriteFile(location . "\README.md", readme)
    }

    static WriteGitignore(location) {
        ignore := "__pycache__/`n*.pyc`n.env`n.venv/`nvenv/`n.log`n"
        MCPServerScaffolding.WriteFile(location . "\.gitignore", ignore)
    }

    static WriteFile(path, content) {
        try {
            FileDelete(path)
        } catch {
        }
        FileAppend(content, path, "UTF-8")
    }

    static ShowHelp(*) {
        help := "🚀 MCP Server Scaffolding Tool" . "`n`n"
        help .= "1. Enter a project name and description." . "`n"
        help .= "2. Pick a template and optional features." . "`n"
        help .= "3. Press Generate or use Ctrl+Alt+M." . "`n`n"
        help .= "Creates FastMCP-ready structure with help/status/ping tools, custom template tools, README, and config stub." . "`n`n"
        help .= "Hotkeys: Ctrl+Alt+M generate, F9 preview, Escape hide." . "`n"
        MCPServerScaffolding.ShowNotification("MCP Scaffolding", "Help dialog shown in log.")
    }

    static HideWindow(*) {
        if !MCPServerScaffolding.gui
            return
        if !WinActive("ahk_id " MCPServerScaffolding.gui.Hwnd)
            return
        MCPServerScaffolding.gui.Hide()
        if (MCPServerScaffolding.statusBar) {
            MCPServerScaffolding.statusBar.SetText("GUI hidden. Press Ctrl+Alt+M to reopen.")
        }
    }

    static Slug(text) {
        sanitized := RegExReplace(text, "[^A-Za-z0-9_-]", "-")
        sanitized := RegExReplace(sanitized, "-+", "-")
        return Trim(sanitized, "-")
    }

    static ShowNotification(title, message, durationMs := 10000) {
        try {
            display := title ? (title . ": " . message) : message
            ToolTip(display, 30, 30)
            SetTimer((*) => ToolTip(), -Abs(durationMs))
        } catch as e {
            MCPServerScaffolding.AppendLog("Notification failed: " . e.Message, "WARN")
        }
    }

    static JsonEscape(value) {
        text := value ?? ""
        backslash := Chr(92)
        quote := Chr(34)
        text := StrReplace(text, backslash, backslash backslash)
        text := StrReplace(text, quote, backslash quote)
        text := StrReplace(text, "`r`n", "\n")
        text := StrReplace(text, "`n", "\n")
        text := StrReplace(text, "`r", "\n")
        return text
    }
}

MCPServerScaffolding.Init()

OnExit((*) => MCPServerScaffolding.AppendLog("Script exiting."))


