; ==============================================================================
; MCP Server Scaffolding Tool
; @name: MCP Server Scaffolding Tool
; @version: 1.0.0
; @description: Generate complete MCP server projects with FastMCP 2.12+ patterns
; @category: development
; @author: Sandra
; @hotkeys: ^!m, F9
; @enabled: true
; ==============================================================================

#Requires AutoHotkey v2.0+
#SingleInstance Force

class MCPScaffolding {
    static projectDir := ""
    static templateDir := ""
    
    static Init() {
        this.projectDir := A_ScriptDir . "\mcp_projects"
        this.templateDir := A_ScriptDir . "\mcp_templates"
        this.CreateGUI()
    }
    
    static CreateGUI() {
        gui := Gui("+Resize +MinSize700x500", "MCP Server Scaffolding Tool")
        gui.BackColor := "0x1a1a1a"
        gui.SetFont("s10 cWhite", "Segoe UI")
        
        ; Title
        gui.Add("Text", "x20 y20 w660 Center Bold", "ðŸš€ MCP Server Scaffolding Tool")
        gui.Add("Text", "x20 y50 w660 Center c0xcccccc", "Generate complete MCP server projects with FastMCP 2.12+ patterns")
        
        ; Project details section
        gui.Add("Text", "x20 y90 w660 Bold", "ðŸ“‹ Project Details")
        
        ; Project name
        gui.Add("Text", "x20 y120 w150", "Project Name:")
        projectNameEdit := gui.Add("Edit", "x180 y115 w200 h25", "my-mcp-server")
        
        ; Project description
        gui.Add("Text", "x20 y155 w150", "Description:")
        descriptionEdit := gui.Add("Edit", "x180 y150 w400 h25", "A Claude MCP server for automation")
        
        ; Project directory
        gui.Add("Text", "x20 y190 w150", "Directory:")
        dirEdit := gui.Add("Edit", "x180 y185 w400 h25", this.projectDir . "\my-mcp-server")
        
        ; Template selection
        gui.Add("Text", "x20 y225 w660 Bold", "ðŸ“ Template Selection")
        
        templateList := gui.Add("ListBox", "x20 y250 w660 h120", [
            "Basic MCP Server - Simple tool registration",
            "Advanced MCP Server - Complex workflows with state management", 
            "File Operations MCP - File system automation",
            "Web Scraping MCP - HTTP requests and data extraction",
            "Database MCP - Database operations and queries",
            "AI Integration MCP - LLM and AI service integration"
        ])
        
        ; Features section
        gui.Add("Text", "x20 y385 w660 Bold", "âœ¨ Features to Include")
        
        ; Checkboxes for features
        featuresPanel := gui.Add("Text", "x20 y410 w660 h80")
        
        ; Create checkboxes dynamically
        features := [
            "Error handling with try-catch blocks",
            "Comprehensive logging system", 
            "Type hints for all functions",
            "Configuration management",
            "Health check endpoints",
            "Rate limiting protection",
            "Input validation",
            "Documentation generation"
        ]
        
        checkboxes := []
        for i, feature in features {
            row := (i - 1) // 2
            col := (i - 1) % 2
            x := 20 + (col * 320)
            y := 410 + (row * 25)
            cb := gui.Add("CheckBox", "x" . x . " y" . y . " w300", feature)
            cb.Value := 1  ; Checked by default
            checkboxes.Push(cb)
        }
        
        ; Generate button
        generateBtn := gui.Add("Button", "x20 y500 w200 h50", "ðŸš€ Generate MCP Server")
        generateBtn.OnEvent("Click", (*) => this.GenerateProject(gui, projectNameEdit, descriptionEdit, dirEdit, templateList, checkboxes))
        
        ; Preview button
        previewBtn := gui.Add("Button", "x240 y500 w200 h50", "ðŸ‘ï¸ Preview Structure")
        previewBtn.OnEvent("Click", (*) => this.PreviewStructure(gui, projectNameEdit, templateList, checkboxes))
        
        ; Help button
        helpBtn := gui.Add("Button", "x460 y500 w200 h50", "â“ Help")
        helpBtn.OnEvent("Click", this.ShowHelp.Bind(this))
        
        ; Status
        gui.Add("Text", "x20 y560 w660 Center c0x888888", "Hotkeys: Ctrl+Alt+M (Generate) | F9 (Preview) | Press Generate to create your MCP server")
        
        ; Set up hotkeys
        this.SetupHotkeys(gui, projectNameEdit, descriptionEdit, dirEdit, templateList, checkboxes)
        
        gui.Show("w700 h600")
    }
    
    static GenerateProject(gui, projectNameEdit, descriptionEdit, dirEdit, templateList, checkboxes) {
        projectName := projectNameEdit.Text
        description := descriptionEdit.Text
        projectDir := dirEdit.Text
        templateIndex := templateList.Value
        selectedFeatures := []
        
        ; Get selected features
        for cb in checkboxes {
            if (cb.Value) {
                selectedFeatures.Push(cb.Text)
            }
        }
        
        if (projectName = "") {
            MsgBox("Please enter a project name!", "Error", "Iconx")
            return
        }
        
        try {
            ; Create project directory
            if (!DirExist(projectDir)) {
                DirCreate(projectDir)
            }
            
            ; Generate project files
            this.GenerateMainFile(projectDir, projectName, description, templateIndex, selectedFeatures)
            this.GenerateRequirements(projectDir, templateIndex)
            this.GenerateConfig(projectDir, projectName)
            this.GenerateReadme(projectDir, projectName, description, selectedFeatures)
            this.GenerateGitignore(projectDir)
            
            ; Show success message
            successText := "âœ… MCP Server Generated Successfully!`n`n"
            successText .= "Project: " . projectName . "`n"
            successText .= "Location: " . projectDir . "`n`n"
            successText .= "Next steps:`n"
            successText .= "1. Install dependencies: pip install -r requirements.txt`n"
            successText .= "2. Configure Claude Desktop config`n"
            successText .= "3. Test the server: python main.py`n"
            successText .= "4. Add to Claude Desktop MCP servers"
            
            MsgBox(successText, "MCP Server Generated", "Iconi")
            
            ; Open project directory
            Run("explorer " . projectDir)
            
        } catch as e {
            MsgBox("Error generating project: " . e.Message, "Error", "Iconx")
        }
    }
    
    static GenerateMainFile(projectDir, projectName, description, templateIndex, features) {
        templates := [
            "basic", "advanced", "file_ops", "web_scraping", "database", "ai_integration"
        ]
        template := templates[templateIndex]
        
        mainContent := this.GetMainFileTemplate(template, projectName, description, features)
        FileAppend(mainContent, projectDir . "\main.py")
    }
    
    static GetMainFileTemplate(template, projectName, description, features) {
        baseTemplate := "; " . projectName . " - " . description . "`n"
        baseTemplate .= "; Generated by MCP Scaffolding Tool`n`n"
        
        switch template {
            case "basic":
                return this.GetBasicTemplate(projectName, features)
            case "advanced":
                return this.GetAdvancedTemplate(projectName, features)
            case "file_ops":
                return this.GetFileOpsTemplate(projectName, features)
            case "web_scraping":
                return this.GetWebScrapingTemplate(projectName, features)
            case "database":
                return this.GetDatabaseTemplate(projectName, features)
            case "ai_integration":
                return this.GetAITemplate(projectName, features)
            default:
                return this.GetBasicTemplate(projectName, features)
        }
    }
    
    static GetBasicTemplate(projectName, features) {
        template := "from mcp.server import Server`n"
        template .= "from mcp.types import Tool`n`n"
        template .= "app = Server('" . projectName . "')`n`n"
        template .= "@app.tool()`n"
        template .= "async def hello_world() -> str:`n"
        template .= "    \"\"\"A simple hello world tool.\"\"\"`n"
        template .= "    return 'Hello from " . projectName . "!'`n`n"
        template .= "if __name__ == '__main__':`n"
        template .= "    app.run()`n"
        return template
    }
    
    static GetAdvancedTemplate(projectName, features) {
        template := "from mcp.server import Server`n"
        template .= "from mcp.types import Tool, State`n"
        template .= "import logging`n`n"
        template .= "# Configure logging`n"
        template .= "logging.basicConfig(level=logging.INFO)`n"
        template .= "logger = logging.getLogger(__name__)`n`n"
        template .= "app = Server('" . projectName . "')`n`n"
        template .= "# Global state management`n"
        template .= "state = State()`n`n"
        template .= "@app.tool()`n"
        template .= "async def process_data(data: str) -> str:`n"
        template .= "    \"\"\"Process input data with state management.\"\"\"`n"
        template .= "    try:`n"
        template .= "        logger.info(f'Processing data: {data}')`n"
        template .= "        # Add your processing logic here`n"
        template .= "        result = f'Processed: {data}'`n"
        template .= "        state.set('last_result', result)`n"
        template .= "        return result`n"
        template .= "    except Exception as e:`n"
        template .= "        logger.error(f'Error processing data: {e}')`n"
        template .= "        raise`n`n"
        template .= "if __name__ == '__main__':`n"
        template .= "    app.run()`n"
        return template
    }
    
    static GetFileOpsTemplate(projectName, features) {
        template := "from mcp.server import Server`n"
        template .= "from mcp.types import Tool`n"
        template .= "import os`n"
        template .= "import shutil`n`n"
        template .= "app = Server('" . projectName . "')`n`n"
        template .= "@app.tool()`n"
        template .= "async def list_files(directory: str) -> str:`n"
        template .= "    \"\"\"List files in a directory.\"\"\"`n"
        template .= "    try:`n"
        template .= "        files = os.listdir(directory)`n"
        template .= "        return f'Files in {directory}: {files}'`n"
        template .= "    except Exception as e:`n"
        template .= "        return f'Error: {e}'`n`n"
        template .= "if __name__ == '__main__':`n"
        template .= "    app.run()`n"
        return template
    }
    
    static GetWebScrapingTemplate(projectName, features) {
        template := "from mcp.server import Server`n"
        template .= "from mcp.types import Tool`n"
        template .= "import requests`n`n"
        template .= "app = Server('" . projectName . "')`n`n"
        template .= "@app.tool()`n"
        template .= "async def fetch_url(url: str) -> str:`n"
        template .= "    \"\"\"Fetch content from a URL.\"\"\"`n"
        template .= "    try:`n"
        template .= "        response = requests.get(url)`n"
        template .= "        return f'Status: {response.status_code}, Content: {response.text[:200]}...'`n"
        template .= "    except Exception as e:`n"
        template .= "        return f'Error: {e}'`n`n"
        template .= "if __name__ == '__main__':`n"
        template .= "    app.run()`n"
        return template
    }
    
    static GetDatabaseTemplate(projectName, features) {
        template := "from mcp.server import Server`n"
        template .= "from mcp.types import Tool`n"
        template .= "import sqlite3`n`n"
        template .= "app = Server('" . projectName . "')`n`n"
        template .= "@app.tool()`n"
        template .= "async def query_database(query: str) -> str:`n"
        template .= "    \"\"\"Execute a database query.\"\"\"`n"
        template .= "    try:`n"
        template .= "        conn = sqlite3.connect('database.db')`n"
        template .= "        cursor = conn.execute(query)`n"
        template .= "        results = cursor.fetchall()`n"
        template .= "        conn.close()`n"
        template .= "        return f'Results: {results}'`n"
        template .= "    except Exception as e:`n"
        template .= "        return f'Error: {e}'`n`n"
        template .= "if __name__ == '__main__':`n"
        template .= "    app.run()`n"
        return template
    }
    
    static GetAITemplate(projectName, features) {
        template := "from mcp.server import Server`n"
        template .= "from mcp.types import Tool`n"
        template .= "import openai`n`n"
        template .= "app = Server('" . projectName . "')`n`n"
        template .= "@app.tool()`n"
        template .= "async def generate_text(prompt: str) -> str:`n"
        template .= "    \"\"\"Generate text using AI.\"\"\"`n"
        template .= "    try:`n"
        template .= "        # Add your AI integration logic here`n"
        template .= "        return f'Generated response for: {prompt}'`n"
        template .= "    except Exception as e:`n"
        template .= "        return f'Error: {e}'`n`n"
        template .= "if __name__ == '__main__':`n"
        template .= "    app.run()`n"
        return template
    }
    
    static GenerateRequirements(projectDir, templateIndex) {
        requirements := "fastmcp>=2.12.1`n"
        
        templates := ["basic", "advanced", "file_ops", "web_scraping", "database", "ai_integration"]
        template := templates[templateIndex]
        
        switch template {
            case "web_scraping":
                requirements .= "requests>=2.31.0`n"
            case "database":
                requirements .= "sqlite3`n"
            case "ai_integration":
                requirements .= "openai>=1.0.0`n"
        }
        
        FileAppend(requirements, projectDir . "\requirements.txt")
    }
    
    static GenerateConfig(projectDir, projectName) {
        configContent := "{`n"
        configContent .= "  \"mcpServers\": {`n"
        configContent .= "    \"" . projectName . "\": {`n"
        configContent .= "      \"command\": \"python\",`n"
        configContent .= "      \"args\": [\"main.py\"],`n"
        configContent .= "      \"cwd\": \"" . projectDir . "\"`n"
        configContent .= "    }`n"
        configContent .= "  }`n"
        configContent .= "}`n"
        
        FileAppend(configContent, projectDir . "\claude_config.json")
    }
    
    static GenerateReadme(projectDir, projectName, description, features) {
        readmeContent := "# " . projectName . "`n`n"
        readmeContent .= description . "`n`n"
        readmeContent .= "## Installation`n`n"
        readmeContent .= "1. Install dependencies:`n"
        readmeContent .= "   ```bash`n"
        readmeContent .= "   pip install -r requirements.txt`n"
        readmeContent .= "   ````n`n"
        readmeContent .= "2. Add to Claude Desktop config:`n"
        readmeContent .= "   Copy the contents of `claude_config.json` to your Claude Desktop configuration.`n`n"
        readmeContent .= "## Features`n`n"
        for feature in features {
            readmeContent .= "- " . feature . "`n"
        }
        readmeContent .= "`n## Usage`n`n"
        readmeContent .= "Run the server:`n"
        readmeContent .= "```bash`n"
        readmeContent .= "python main.py`n"
        readmeContent .= "````n`n"
        readmeContent .= "## Generated by MCP Scaffolding Tool`n"
        
        FileAppend(readmeContent, projectDir . "\README.md")
    }
    
    static GenerateGitignore(projectDir) {
        gitignoreContent := "__pycache__/`n"
        gitignoreContent .= "*.pyc`n"
        gitignoreContent .= "*.pyo`n"
        gitignoreContent .= "*.pyd`n"
        gitignoreContent .= ".Python`n"
        gitignoreContent .= "env/`n"
        gitignoreContent .= "venv/`n"
        gitignoreContent .= ".venv`n"
        gitignoreContent .= ".env`n"
        gitignoreContent .= "*.log`n"
        gitignoreContent .= ".DS_Store`n"
        
        FileAppend(gitignoreContent, projectDir . "\.gitignore")
    }
    
    static PreviewStructure(gui, projectNameEdit, templateList, checkboxes) {
        projectName := projectNameEdit.Text
        templateIndex := templateList.Value
        selectedFeatures := []
        
        for cb in checkboxes {
            if (cb.Value) {
                selectedFeatures.Push(cb.Text)
            }
        }
        
        templates := [
            "Basic MCP Server", "Advanced MCP Server", "File Operations MCP", 
            "Web Scraping MCP", "Database MCP", "AI Integration MCP"
        ]
        template := templates[templateIndex]
        
        previewText := "ðŸ“ Project Structure Preview`n`n"
        previewText .= "Project: " . projectName . "`n"
        previewText .= "Template: " . template . "`n`n"
        previewText .= "Files to be generated:`n"
        previewText .= "â”œâ”€â”€ main.py (Main server file)`n"
        previewText .= "â”œâ”€â”€ requirements.txt (Dependencies)`n"
        previewText .= "â”œâ”€â”€ claude_config.json (Claude Desktop config)`n"
        previewText .= "â”œâ”€â”€ README.md (Documentation)`n"
        previewText .= "â””â”€â”€ .gitignore (Git ignore file)`n`n"
        previewText .= "Selected Features:`n"
        for feature in selectedFeatures {
            previewText .= "â€¢ " . feature . "`n"
        }
        
        MsgBox(previewText, "Project Structure Preview", "Iconi")
    }
    
    static ShowHelp(*) {
        helpText := "ðŸš€ MCP Server Scaffolding Tool Help`n`n"
        helpText .= "This tool generates complete MCP server projects with:`n`n"
        helpText .= "ðŸ“‹ Project Details:`n"
        helpText .= "â€¢ Project Name: Choose a unique name for your MCP server`n"
        helpText .= "â€¢ Description: Brief description of what your server does`n"
        helpText .= "â€¢ Directory: Where to create the project files`n`n"
        helpText .= "ðŸ“ Templates:`n"
        helpText .= "â€¢ Basic: Simple tool registration`n"
        helpText .= "â€¢ Advanced: Complex workflows with state management`n"
        helpText .= "â€¢ File Ops: File system automation`n"
        helpText .= "â€¢ Web Scraping: HTTP requests and data extraction`n"
        helpText .= "â€¢ Database: Database operations`n"
        helpText .= "â€¢ AI Integration: LLM and AI services`n`n"
        helpText .= "âœ¨ Features:`n"
        helpText .= "Select which features to include in your generated code`n`n"
        helpText .= "Hotkeys:`n"
        helpText .= "â€¢ Ctrl+Alt+M: Generate project`n"
        helpText .= "â€¢ F9: Preview structure`n"
        helpText .= "â€¢ Escape: Close tool"
        
        MsgBox(helpText, "MCP Scaffolding Help", "Iconi")
    }
    
    static SetupHotkeys(gui, projectNameEdit, descriptionEdit, dirEdit, templateList, checkboxes) {
        ^!Hotkey("m", (*) => this.Ge)nerateProject(gui, projectNameEdit, descriptionEdit, dirEdit, templateList, checkboxes)
        Hotkey("F9", (*) => this.PreviewStructure(gui, project)NameEdit, templateList, checkboxes)
        
        Hotkey("Escape", (*) => {
            if (Wi)nExist("MCP Server Scaffolding Tool")) {
                WinClose("MCP Server Scaffolding Tool")
            }
        }
    }
}

; Hotkeys
^!Hotkey("m", (*) => MCPScaffoldi)ng.Init()
Hotkey("F9", (*) => MCPScaffoldi)ng.Init()

; Initialize
MCPScaffolding.Init()

