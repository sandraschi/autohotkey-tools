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


; Suppress error popups - log to file instead
OnError(LogError)

LogError(Thrown, Mode) {
    errorMsg := "Error: " . Thrown.Message . " at line " . Thrown.Line . "`n" . Thrown.Stack
    FileAppend(errorMsg, "mcp_server_scaffolding_errors.log", "UTF-8")
    OutputDebug(errorMsg)  ; Enable LLM debugging
    return 1  ; Suppress popup (1 = suppress, 0 = show)
}


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
        gui.BackColor := "1a1a1a"
        gui.SetFont("s10 cFFFFFF", "Segoe UI")
        
        ; Title
        gui.Add("Text", "x20 y20 w660 Center Bold", "🚀 MCP Server Scaffolding Tool")
        gui.Add("Text", "x20 y50 w660 Center ", "Generate complete MCP server projects with FastMCP 2.12+ patterns")
        
        ; Project details section
        gui.Add("Text", "x20 y90 w660 Bold", "📋 Project Details")
        
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
        gui.Add("Text", "x20 y225 w660 Bold", "📁 Template Selection")
        
        templateList := gui.Add("ListBox", "x20 y250 w660 h120", [
            "Basic MCP Server - Simple tool registration",
            "Advanced MCP Server - Complex workflows with state management", 
            "File Operations MCP - File system automation",
            "Web Scraping MCP - HTTP requests and data extraction",
            "Database MCP - Database operations and queries",
            "AI Integration MCP - LLM and AI service integration"
        ])
        
        ; Features section
        gui.Add("Text", "x20 y385 w660 Bold", "✨ Features to Include")
        
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
            col := Mod(i - 1, 2)
            x := 20 + (col * 320)
            y := 410 + (row * 25)
            cb := gui.Add("CheckBox", "x" . x . " y" . y . " w300", feature)
            cb.Value := 1  ; Checked by default
            checkboxes.Push(cb)
        }
        
        ; Generate button
        generateBtn := gui.Add("Button", "x20 y500 w200 h50", "🚀 Generate MCP Server")
        generateBtn.OnEvent("Click", (*) => MCPScaffolding.GenerateProject(gui, projectNameEdit, descriptionEdit, dirEdit, templateList, checkboxes))
        
        ; Preview button
        previewBtn := gui.Add("Button", "x240 y500 w200 h50", "👁️ Preview Structure")
        previewBtn.OnEvent("Click", (*) => MCPScaffolding.PreviewStructure(gui, projectNameEdit, templateList, checkboxes))
        
        ; Help button
        helpBtn := gui.Add("Button", "x460 y500 w200 h50", "❓ Help")
        helpBtn.OnEvent("Click", this.ShowHelp.Bind(this))
        
        ; Status
        gui.Add("Text", "x20 y560 w660 Center ", "Hotkeys: Ctrl+Alt+M (Generate) | F9 (Preview) | Press Generate to create your MCP server")
        
        ; Set up hotkeys
        this.SetupHotkeys(gui, projectNameEdit, descriptionEdit, dirEdit, templateList, checkboxes)
        
        gui.Show("w700 h600")
        
        ; Store gui reference
        this.gui := gui
    }
    
    static GenerateProject(gui, projectNameEdit, descriptionEdit, dirEdit, templateList, checkboxes) {
        projectName := projectNameEdit.Value
        description := descriptionEdit.Value
        projectDir := dirEdit.Value
        templateIndex := templateList.Value
        selectedFeatures := []
        
        ; Get selected features
        for cb in checkboxes {
            if (cb.Value) {
                ; CheckBox.Text contains the label text
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
            
            ; Create folder structure
            mcpbDir := projectDir . "\mcpb"
            srcDir := projectDir . "\src"
            toolsDir := srcDir . "\tools"
            
            if (!DirExist(mcpbDir)) {
                DirCreate(mcpbDir)
            }
            if (!DirExist(srcDir)) {
                DirCreate(srcDir)
            }
            if (!DirExist(toolsDir)) {
                DirCreate(toolsDir)
            }
            
            ; Generate project files
            this.GenerateMainFile(projectDir, projectName, description, templateIndex, selectedFeatures)
            this.GenerateToolsModule(toolsDir, projectName, templateIndex)
            this.GenerateRequirements(projectDir, templateIndex)
            this.GeneratePyProject(projectDir, projectName, description)
            this.GenerateConfig(projectDir, projectName)
            this.GenerateReadme(projectDir, projectName, description, selectedFeatures)
            this.GenerateGitignore(projectDir)
            this.GenerateMCBPFiles(mcpbDir, projectName, description)
            
            ; Show success message
            successText := "✅ MCP Server Generated Successfully!`n`n"
            successText .= "Project: " . projectName . "`n"
            successText .= "Location: " . projectDir . "`n`n"
            successText .= "Next steps:`n"
            successText .= "1. Run setup: cd mcpb`n"
            successText .= "   Then run: setup.bat`n"
            successText .= "2. Install dependencies: pip install -r requirements.txt`n"
            successText .= "3. Configure Claude Desktop config (copy claude_config.json)`n"
            successText .= "4. Test the server: python main.py`n"
            successText .= "5. Add to Claude Desktop MCP servers`n`n"
            successText .= "Standard tools available: help, status, ping"
            
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
        
        ; Make main.py executable on Unix systems (if converted)
        ; This is just for completeness - Windows doesn't need it
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
        template := "#!/usr/bin/env python3`n"
        template .= "\"\"\"`n"
        template .= projectName . " - Main server file`n"
        template .= "Generated by MCP Scaffolding Tool`n"
        template .= "\"\"\"`n`n"
        template .= "from fastmcp import FastMCP`n"
        template .= "from src.tools import register_standard_tools, register_custom_tools`n"
        template .= "import logging`n`n"
        template .= "# Configure logging`n"
        template .= "logging.basicConfig(`n"
        template .= "    level=logging.INFO,`n"
        template .= "    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s'`n"
        template .= ")`n"
        template .= "logger = logging.getLogger(__name__)`n`n"
        template .= "# Create FastMCP server`n"
        template .= "mcp = FastMCP('" . projectName . "')`n`n"
        template .= "# Register standard tools (help, status, ping)`n"
        template .= "register_standard_tools(mcp)`n`n"
        template .= "# Register custom tools`n"
        template .= "register_custom_tools(mcp)`n`n"
        template .= "if __name__ == '__main__':`n"
        template .= "    logger.info(f'Starting {mcp.name} MCP server...')`n"
        template .= "    mcp.run()`n"
        return template
    }
    
    static GetAdvancedTemplate(projectName, features) {
        ; All templates now use FastMCP 2.12 with stdio
        return this.GetBasicTemplate(projectName, features)
    }
    
    static GetFileOpsTemplate(projectName, features) {
        ; All templates now use FastMCP 2.12 with stdio
        return this.GetBasicTemplate(projectName, features)
    }
    
    static GetWebScrapingTemplate(projectName, features) {
        ; All templates now use FastMCP 2.12 with stdio
        return this.GetBasicTemplate(projectName, features)
    }
    
    static GetDatabaseTemplate(projectName, features) {
        ; All templates now use FastMCP 2.12 with stdio
        return this.GetBasicTemplate(projectName, features)
    }
    
    static GetAITemplate(projectName, features) {
        ; All templates now use FastMCP 2.12 with stdio
        return this.GetBasicTemplate(projectName, features)
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
        ; Generate Claude Desktop config with stdio transport (default)
        ; No "transport" field = stdio (standard input/output) communication
        ; FastMCP 2.12+ automatically uses stdio when running via mcp.run()
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
    
    static GenerateToolsFile(toolsDir, projectName, templateIndex) {
        toolsContent := this.GetToolsTemplate(projectName, templateIndex)
        
        ; Create __init__.py
        initContent := "from .tools import register_tools`n`n"
        initContent .= "__all__ = ['register_tools']`n"
        FileAppend(initContent, toolsDir . "\__init__.py")
        
        ; Create tools.py
        FileAppend(toolsContent, toolsDir . "\tools.py")
    }
    
    static GetToolsTemplate(projectName, templateIndex) {
        template := "#!/usr/bin/env python3`n"
        template .= "\"\"\"`n"
        template .= "MCP Server Tools - Standardized tool definitions`n"
        template .= "Generated by MCP Scaffolding Tool`n"
        template .= "\"\"\"`n`n"
        template .= "import logging`n"
        template .= "from typing import Dict, Any, Optional`n`n"
        template .= "logger = logging.getLogger(__name__)`n`n"
        template .= "def register_tools(mcp):`n"
        template .= "    \"\"\"Register all tools with the FastMCP server.\"\"\"`n"
        template .= "    `n"
        template .= "    # Standard tools - always included`n"
        template .= "    @mcp.tool()`n"
        template .= "    async def help(topic: Optional[str] = None) -> Dict[str, Any]:`n"
        template .= "        \"\"\"`n"
        template .= "        Get help information about available tools.`n`n"
        template .= "        Args:`n"
        template .= "            topic: Optional topic to get specific help for`n`n"
        template .= "        Returns:`n"
        template .= "            Dictionary with help information`n"
        template .= "        \"\"\"`n"
        template .= "        try:`n"
        template .= "            available_tools = ['help', 'status']`n"
        template .= "            `n"
        template .= "            if topic:`n"
        template .= "                # Return specific help for topic`n"
        template .= "                return {`n"
        template .= "                    'topic': topic,`n"
        template .= "                    'help': f'Help information for {topic} will be displayed here.'`n"
        template .= "                }`n"
        template .= "            else:`n"
        template .= "                # Return general help`n"
        template .= "                return {`n"
        template .= "                    'server': '" . projectName . "',`n"
        template .= "                    'available_tools': available_tools,`n"
        template .= "                    'description': 'MCP server generated by scaffolding tool',`n"
        template .= "                    'usage': 'Use help(topic=\"tool_name\") for specific help'`n"
        template .= "                }`n"
        template .= "        except Exception as e:`n"
        template .= "            logger.error(f'Error in help tool: {e}')`n"
        template .= "            return {'error': str(e)}`n"
        template .= "    `n"
        template .= "    @mcp.tool()`n"
        template .= "    async def status() -> Dict[str, Any]:`n"
        template .= "        \"\"\"`n"
        template .= "        Get server status and health information.`n`n"
        template .= "        Returns:`n"
        template .= "            Dictionary with server status information`n"
        template .= "        \"\"\" communication`n"
        template .= "        try:`n"
        template .= "            import sys`n"
        template .= "            import platform`n"
        template .= "            `n"
        template .= "            return {`n"
        template .= "                'server': '" . projectName . "',`n"
        template .= "                'status': 'running',`n"
        template .= "                'python_version': sys.version,`n"
        template .= "                'platform': platform.platform(),`n"
        template .= "                'health': 'healthy'`n"
        template .= "            }`n"
        template .= "        except Exception as e:`n"
        template .= "            logger.error(f'Error in status tool: {e}')`n"
        template .= "            return {'error': str(e), 'status': 'error'}`n"
        template .= "    `n"
        template .= "    # Template-specific tools will be added here`n"
        template .= "    # Add your custom tools below:`n"
        
        ; Add template-specific tool examples
        templates := ["basic", "advanced", "file_ops", "web_scraping", "database", "ai_integration"]
        templateName := templates[templateIndex]
        
        switch templateName {
            case "basic":
                template .= "    `n"
                template .= "    @mcp.tool()`n"
                template .= "    async def hello_world() -> str:`n"
                template .= "        \"\"\"A simple hello world tool.\"\"\"`n"
                template .= "        return 'Hello from " . projectName . "!'`n"
            case "file_ops":
                template .= "    `n"
                template .= "    @mcp.tool()`n"
                template .= "    async def list_files(directory: str) -> Dict[str, Any]:`n"
                template .= "        \"\"\"List files in a directory.\"\"\"`n"
                template .= "        import os`n"
                template .= "        try:`n"
                template .= "            files = os.listdir(directory)`n"
                template .= "            return {'directory': directory, 'files': files}`n"
                template .= "        except Exception as e:`n"
                template .= "            return {'error': str(e)}`n"
        }
        
        return template
    }
    
    static GeneratePyProject(projectDir, projectName, description) {
        pyprojectContent := "[build-system]`n"
        pyprojectContent .= "requires = [\"setuptools>=61.0\", \"wheel\"]`n"
        pyprojectContent .= "build-backend = \"setuptools.build_meta\"`n`n"
        pyprojectContent .= "[project]`n"
        pyprojectContent .= "name = \"" . projectName . "\"`n"
        pyprojectContent .= "version = \"1.0.0\"`n"
        pyprojectContent .= "description = \"" . description . "\"`n"
        pyprojectContent .= "requires-python = \">=3.10\"`n"
        pyprojectContent .= "dependencies = [`n"
        pyprojectContent .= "    \"fastmcp>=2.12.1\",`n"
        pyprojectContent .= "]`n`n"
        pyprojectContent .= "[project.optional-dependencies]`n"
        pyprojectContent .= "dev = [`n"
        pyprojectContent .= "    \"pytest>=7.0.0\",`n"
        pyprojectContent .= "    \"pytest-asyncio>=0.21.0\",`n"
        pyprojectContent .= "]`n"
        
        FileAppend(pyprojectContent, projectDir . "\pyproject.toml")
    }
    
    static GenerateToolsModule(toolsDir, projectName, templateIndex) {
        ; Generate __init__.py
        initContent := "\"\"\"Tools module for " . projectName . "\"\"\"`n"
        initContent .= "from .standard_tools import register_standard_tools`n"
        initContent .= "from .custom_tools import register_custom_tools`n`n"
        initContent .= "__all__ = ['register_standard_tools', 'register_custom_tools']`n"
        FileAppend(initContent, toolsDir . "\__init__.py")
        
        ; Generate standard_tools.py with help, status, ping
        this.GenerateStandardTools(toolsDir, projectName)
        
        ; Generate custom_tools.py based on template
        this.GenerateCustomTools(toolsDir, projectName, templateIndex)
    }
    
    static GenerateStandardTools(toolsDir, projectName) {
        content := "#!/usr/bin/env python3`n"
        content .= "\"\"\"`n"
        content .= "Standard MCP tools - Help, Status, and Health Check`n"
        content .= "These tools are included in every MCP server by default.`n"
        content .= "\"\"\"`n`n"
        content .= "from fastmcp import FastMCP`n"
        content .= "from typing import Dict, Any`n"
        content .= "import platform`n"
        content .= "import sys`n"
        content .= "from datetime import datetime`n`n"
        content .= "def register_standard_tools(mcp: FastMCP) -> None:`n"
        content .= "    \"\"\"Register standard tools available in every MCP server.`n"
        content .= "    `n"
        content .= "    Args:`n"
        content .= "        mcp: FastMCP server instance`n"
        content .= "    \"\" dodat \"`n`n"
        content .= "    @mcp.tool()`n"
        content .= "    def help() -> Dict[str, Any]:`n"
        content .= "        \"\"\"Get help information about this MCP server.`n"
        content .= "        `n"
        content .= "        Returns:`n"
        content .= "            Dictionary containing server name, description, and available tools`n"
        content .= "        \"\"\"`n"
        content .= "        tools_info = []`n"
        content .= "        for tool_name, tool_func in mcp._tools.items():`n"
        content .= "            tools_info.append({`n"
        content .= "                'name': tool_name,`n"
        content .= "                'description': tool_func.__doc__ or 'No description available'`n"
        content .= "            })`n"
        content .= "        `n"
        content .= "        return {`n"
        content .= "            'server': '" . projectName . "',`n"
        content .= "            'description': 'MCP server generated by scaffolding tool',`n"
        content .= "            'version': '1.0.0',`n"
        content .= "            'available_tools': tools_info,`n"
        content .= "            'total_tools': len(tools_info)`n"
        content .= "        }`n`n"
        content .= "    @mcp.tool()`n"
        content .= "    def status() -> Dict[str, Any]:`n"
        content .= "        \"\"\"Get current status and health information.`n"
        content .= "        `n"
        content .= "        Returns:`n"
        content .= "            Dictionary containing server status, system info, and health check`n"
        content .= "        \"\"\"`n"
        content .= "        return {`n"
        content .= "            'status': 'running',`n"
        content .= "            'timestamp': datetime.now().isoformat(),`n"
        content .= "            'server_name': '" . projectName . "',`n"
        content .= "            'version': '1.0.0',`n"
        content .= "            'python_version': sys.version,`n"
        content .= "            'platform': platform.platform(),`n"
        content .= "            'system': platform.system(),`n"
        content .= "            'architecture': platform.machine()`n"
        content .= "        }`n`n"
        content .= "    @mcp.tool()`n"
        content .= "    def ping(message: str = 'pong') -> Dict[str, Any]:`n"
        content .= "        \"\"\"Health check endpoint - responds with ping/pong.`n"
        content .= "        `n"
        content .= "        Args:`n"
        content .= "            message: Custom message to echo back (default: 'pong')`n"
        content .= "        `n"
        content .= "        Returns:`n"
        content .= "            Dictionary with ping response and timestamp`n"
        content .= "        \"\"\"`n"
        content .= "        return {`n"
        content .= "            'status': 'ok',`n"
        content .= "            'message': message,`n"
        content .= "            'timestamp': datetime.now().isoformat(),`n"
        content .= "            'server': '" . projectName . "'`n"
        content .= "        }`n"
        
        FileAppend(content, toolsDir . "\standard_tools.py")
    }
    
    static GenerateCustomTools(toolsDir, projectName, templateIndex) {
        templates := [
            "basic", "advanced", "file_ops", "web_scraping", "database", "ai_integration"
        ]
        template := templates[templateIndex]
        
        content := "#!/usr/bin/env python3`n"
        content .= "\"\"\"`n"
        content .= "Custom tools for " . projectName . "`n"
        content .= "Generated based on " . template . " template`n"
        content .= "\"\"\"`n`n"
        content .= "from fastmcp import FastMCP`n"
        content .= "from typing import Dict, Any`n`n"
        content .= "def register_custom_tools(mcp: FastMCP) -> None:`n"
        content .= "    \"\"\"Register custom tools specific to this MCP server.`n"
        content .= "    `n"
        content .= "    Args:`n"
        content .= "        mcp: FastMCP server instance`n"
        content .= "    \"\"\"`n"
        
        switch template {
            case "basic":
                content .= this.GetBasicCustomTools(projectName)
            case "advanced":
                content .= this.GetAdvancedCustomTools(projectName)
            case "file_ops":
                content .= this.GetFileOpsCustomTools(projectName)
            case "web_scraping":
                content .= this.GetWebScrapingCustomTools(projectName)
            case "database":
                content .= this.GetDatabaseCustomTools(projectName)
            case "ai_integration":
                content .= this.GetAICustomTools(projectName)
            default:
                content .= this.GetBasicCustomTools(projectName)
        }
        
        FileAppend(content, toolsDir . "\custom_tools.py")
    }
    
    static GetBasicCustomTools(projectName) {
        content := "    @mcp.tool()`n"
        content .= "    def hello_world() -> str:`n"
        content .= "        \"\"\"A simple hello world tool.`n"
        content .= "        `n"
        content .= "        Returns:`n"
        content .= "            Greeting message`n"
        content .= "        \"\"\"`n"
        content .= "        return 'Hello from " . projectName . "!'`n"
        return content
    }
    
    static GetAdvancedCustomTools(projectName) {
        content := "    @mcp.tool()`n"
        content .= "    def process_data(data: str) -> Dict[str, Any]:`n"
        content .= "        \"\"\"Process input data with advanced processing.`n"
        content .= "        `n"
        content .= "        Args:`n"
        content .= "            data: Input data to process`n"
        content .= "        `n"
        content .= "        Returns:`n"
        content .= "            Processed data result`n"
        content .= "        \"\"\"`n"
        content .= "        # Add your processing logic here`n"
        content .= "        result = f'Processed: {data}'`n"
        content .= "        return {`n"
        content .= "            'success': True,`n"
        content .= "            'result': result,`n"
        content .= "            'input_length': len(data)`n"
        content .= "        }`n"
        return content
    }
    
    static GetFileOpsCustomTools(projectName) {
        content := "    import os`n"
        content .= "    from pathlib import Path`n`n"
        content .= "    @mcp.tool()`n"
        content .= "    def list_files(directory: str) -> Dict[str, Any]:`n"
        content .= "        \"\"\"List files in a directory.`n"
        content .= "        `n"
        content .= "        Args:`n"
        content .= "            directory: Path to directory to list`n"
        content .= "        `n"
        content .= "        Returns:`n"
        content .= "            Dictionary with file listing`n"
        content .= "        \"\"\"`n"
        content .= "        try:`n"
        content .= "            path = Path(directory)`n"
        content .= "            if not path.exists():`n"
        content .= "                return {'error': f'Directory not found: {directory}'}`n"
        content .= "            files = [f.name for f in path.iterdir() if f.is_file()]`n"
        content .= "            dirs = [d.name for d in path.iterdir() if d.is_dir()]`n"
        content .= "            return {`n"
        content .= "                'directory': directory,`n"
        content .= "                'files': files,`n"
        content .= "                'directories': dirs,`n"
        content .= "                'total_files': len(files)`n"
        content .= "            }`n"
        content .= "        except Exception as e:`n"
        content .= "            return {'error': str(e)}`n"
        return content
    }
    
    static GetWebScrapingCustomTools(projectName) {
        content := "    import requests`n`n"
        content .= "    @mcp.tool()`n"
        content .= "    def fetch_url(url: str) -> Dict[str, Any]:`n"
        content .= "        \"\"\"Fetch content from a URL.`n"
        content .= "        `n"
        content .= "        Args:`n"
        content .= "            url: URL to fetch`n"
        content .= "        `n"
        content .= "        Returns:`n"
        content .= "            Dictionary with response data`n"
        content .= "        \"\"\"`n"
        content .= "        try:`n"
        content .= "            response = requests.get(url, timeout=10)`n"
        content .= "            return {`n"
        content .= "                'url': url,`n"
        content .= "                'status_code': response.status_code,`n"
        content .= "                'content_length': len(response.content),`n"
        content .= "                'content_preview': response.text[:200]`n"
        content .= "            }`n"
        content .= "        except Exception as e:`n"
        content .= "            return {'error': str(e)}`n"
        return content
    }
    
    static GetDatabaseCustomTools(projectName) {
        content := "    import sqlite3`n"
        content .= "    from pathlib import Path`n`n"
        content .= "    @mcp.tool()`n"
        content .= "    def query_database(query: str, db_path: str = 'database.db') -> Dict[str, Any]:`n"
        content .= "        \"\"\"Execute a database query.`n"
        content .= "        `n"
        content .= "        Args:`n"
        content .= "            query: SQL query to execute`n"
        content .= "            db_path: Path to database file`n"
        content .= "        `n"
        content .= "        Returns:`n"
        content .= "            Dictionary with query results`n"
        content .= "        \"\"\"`n"
        content .= "        try:`n"
        content .= "            conn = sqlite3.connect(db_path)`n"
        content .= "            cursor = conn.execute(query)`n"
        content .= "            results = cursor.fetchall()`n"
        content .= "            columns = [desc[0] for desc in cursor.description] if cursor.description else []`n"
        content .= "            conn.close()`n"
        content .= "            return {`n"
        content .= "                'success': True,`n"
        content .= "                'results': results,`n"
        content .= "                'columns': columns,`n"
        content .= "                'row_count': len(results)`n"
        content .= "            }`n"
        content .= "        except Exception as e:`n"
        content .= "            return {'error': str(e)}`n"
        return content
    }
    
    static GetAICustomTools(projectName) {
        content := "    @mcp.tool()`n"
        content .= "    def generate_text(prompt: str) -> Dict[str, Any]:`n"
        content .= "        \"\"\"Generate text using AI.`n"
        content .= "        `n"
        content .= "        Args:`n"
        content .= "            prompt: Text prompt for AI generation`n"
        content .= "        `n"
        content .= "        Returns:`n"
        content .= "            Dictionary with generated text`n"
        content .= "        \"\"\"`n"
        content .= "        try:`n"
        content .= "            # Add your AI integration logic here`n"
        content .= "            # Example: OpenAI, Anthropic, etc.`n"
        content .= "            return {`n"
        content .= "                'success': True,`n"
        content .= "                'prompt': prompt,`n"
        content .= "                'result': f'Generated response for: {prompt}'`n"
        content .= "            }`n"
        content .= "        except Exception as e:`n"
        content .= "            return {'error': str(e)}`n"
        return content
    }
    
    static GenerateMCBPFiles(mcpbDir, projectName, description) {
        ; Generate build script
        buildScript := "@echo off`n"
        buildScript .= "echo Building " . projectName . "...`n"
        buildScript .= "pip install -r ../requirements.txt`n"
        buildScript .= "echo Build complete!`n"
        FileAppend(buildScript, mcpbDir . "\build.bat")
        
        ; Generate setup script
        setupScript := "@echo off`n"
        setupScript .= "echo Setting up " . projectName . "...`n"
        setupScript .= "python -m venv venv`n"
        setupScript .= "call venv\\Scripts\\activate.bat`n"
        setupScript .= "pip install -r ..\\requirements.txt`n"
        setupScript .= "echo Setup complete! Activate with: venv\\Scripts\\activate.bat`n"
        FileAppend(setupScript, mcpbDir . "\setup.bat")
        
        ; Generate README for mcpb
        mcpbReadme := "# MCPB - Build and Scaffolding Files`n`n"
        mcpbReadme .= "This directory contains build scripts and scaffolding metadata.`n`n"
        mcpbReadme .= "## Files`n`n"
        mcpbReadme .= "- `build.bat`: Build script for installing dependencies`n"
        mcpbReadme .= "- `setup.bat`: Initial setup script for creating virtual environment`n"
        mcpbReadme .= "- `scaffold.json`: Metadata about how this project was generated`n`n"
        mcpbReadme .= "## Usage`n`n"
        mcpbReadme .= "Run `setup.bat` for initial setup, or `build.bat` to rebuild.`n"
        FileAppend(mcpbReadme, mcpbDir . "\README.md")
        
        ; Generate scaffold metadata
        scaffoldJson := "{`n"
        scaffoldJson .= "  \"project_name\": \"" . projectName . "\",`n"
        scaffoldJson .= "  \"description\": \"" . description . "\",`n"
        scaffoldJson .= "  \"generated_by\": \"MCP Scaffolding Tool\",`n"
        scaffoldJson .= "  \"generated_at\": \"" . FormatTime(A_Now, "yyyy-MM-dd HH:mm:ss") . "\",`n"
        scaffoldJson .= "  \"template\": \"fastmcp\",`n"
        scaffoldJson .= "  \"standard_tools\": [\"help\", \"status\", \"ping\"]`n"
        scaffoldJson .= "}`n"
        FileAppend(scaffoldJson, mcpbDir . "\scaffold.json")
    }
    
    static PreviewStructure(gui, projectNameEdit, templateList, checkboxes) {
        projectName := projectNameEdit.Value
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
        
        previewText := "📁 Project Structure Preview`n`n"
        previewText .= "Project: " . projectName . "`n"
        previewText .= "Template: " . template . "`n`n"
        previewText .= "Files to be generated:`n"
        previewText .= "├── main.py (Main server file)`n"
        previewText .= "├── src/`n"
        previewText .= "│   └── tools/`n"
        previewText .= "│       ├── __init__.py`n"
        previewText .= "│       ├── standard_tools.py (help, status, ping)`n"
        previewText .= "│       └── custom_tools.py (template-specific tools)`n"
        previewText .= "├── mcpb/`n"
        previewText .= "│   ├── build.bat (Build script)`n"
        previewText .= "│   ├── setup.bat (Setup script)`n"
        previewText .= "│   ├── scaffold.json (Metadata)`n"
        previewText .= "│   └── README.md`n"
        previewText .= "├── pyproject.toml (Python project config)`n"
        previewText .= "├── requirements.txt (Dependencies)`n"
        previewText .= "├── claude_config.json (Claude Desktop config)`n"
        previewText .= "├── README.md (Documentation)`n"
        previewText .= "└── .gitignore (Git ignore file)`n`n"
        previewText .= "Standard Tools Included:`n"
        previewText .= "• help - Get server information and available tools`n"
        previewText .= "• status - Check server status and system info`n"
        previewText .= "• ping - Health check endpoint`n`n"
        previewText .= "Selected Features:`n"
        for feature in selectedFeatures {
            previewText .= "• " . feature . "`n"
        }
        
        MsgBox(previewText, "Project Structure Preview", "Iconi")
    }
    
    static ShowHelp(*) {
        helpText := "🚀 MCP Server Scaffolding Tool Help`n`n"
        helpText .= "This tool generates complete MCP server projects with:`n`n"
        helpText .= "📋 Project Details:`n"
        helpText .= "• Project Name: Choose a unique name for your MCP server`n"
        helpText .= "• Description: Brief description of what your server does`n"
        helpText .= "• Directory: Where to create the project files`n`n"
        helpText .= "📁 Templates:`n"
        helpText .= "• Basic: Simple tool registration`n"
        helpText .= "• Advanced: Complex workflows with state management`n"
        helpText .= "• File Ops: File system automation`n"
        helpText .= "• Web Scraping: HTTP requests and data extraction`n"
        helpText .= "• Database: Database operations`n"
        helpText .= "• AI Integration: LLM and AI services`n`n"
        helpText .= "✨ Features:`n"
        helpText .= "Select which features to include in your generated code`n`n"
        helpText .= "Hotkeys:`n"
        helpText .= "• Ctrl+Alt+M: Generate project`n"
        helpText .= "• F9: Preview structure`n"
        helpText .= "• Escape: Close tool"
        
        MsgBox(helpText, "MCP Scaffolding Help", "Iconi")
    }
    
    static SetupHotkeys(gui, projectNameEdit, descriptionEdit, dirEdit, templateList, checkboxes) {
        Hotkey("^!m", (*) => this.GenerateProject(gui, projectNameEdit, descriptionEdit, dirEdit, templateList, checkboxes))
        Hotkey("F9", (*) => this.PreviewStructure(gui, projectNameEdit, templateList, checkboxes))
        
        Hotkey("Escape", (*) => {
            if (WinExist("MCP Server Scaffolding Tool")) {
                WinClose("MCP Server Scaffolding Tool")
            }
        })
    }
}

; Hotkeys
Hotkey("^!m", (*) => MCPScaffolding.Init())
Hotkey("F9", (*) => MCPScaffolding.Init())

; Initialize
MCPScaffolding.Init()


