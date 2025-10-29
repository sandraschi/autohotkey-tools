# Development Guide

This guide covers development practices, tools, and workflows for the AutoHotkey Scriptlets Collection.

## 🛠️ Development Tools

### Linting System

The project includes a comprehensive linting infrastructure for AutoHotkey v2 development:

#### Core Linting Tools

- **`utils/linter.ahk`** - Main static analyzer
  - Detects AutoHotkey v2 compatibility issues
  - Identifies syntax errors and warnings
  - Generates detailed reports with line numbers
  - Supports comprehensive error categorization

- **`utils/run_linter_clean.ps1`** - Clean runner
  - Automatically kills running AutoHotkey processes
  - Ensures clean execution environment
  - Provides detailed status reporting
  - Handles file path validation

- **`utils/batch_analyze_all.ps1`** - Batch analysis
  - Analyzes all scriptlets in the collection
  - Generates comprehensive reports
  - Provides summary statistics
  - Creates detailed documentation

- **`utils/fix_autohotkey_errors.ps1`** - Automated fixing
  - Automatically fixes common v1→v2 issues
  - Handles hotkey syntax conversion
  - Fixes file operation syntax
  - Adds missing directives

#### Usage Examples

```powershell
# Lint a single scriptlet
.\utils\run_linter_clean.ps1 -ScriptletPath '.\scriptlets\chess_stockfish.ahk'

# Analyze all scriptlets
.\utils\batch_analyze_all.ps1

# Fix common errors automatically
.\utils\fix_autohotkey_errors.ps1
```

### Validation Framework

- **`utils/scriptlet_validator.ahk`** - Advanced validation
  - Comprehensive syntax checking
  - Runtime validation
  - Performance testing
  - Integration testing

## 🚀 MCP Server Development

### MCP Server Scaffolding Tool

Generate complete MCP servers with FastMCP 2.12+ using the scaffolding tool:

**Location**: `scriptlets/mcp_server_scaffolding.ahk`  
**Hotkey**: `Ctrl+Alt+M` or `F9`

**Features:**
- ✅ FastMCP 2.12+ with stdio transport (Claude Desktop compatible)
- ✅ Standard tools: `help()`, `status()`, `ping()`
- ✅ Organized project structure with `src/tools/` modules
- ✅ Build scripts and virtual environment setup
- ✅ Complete Claude Desktop configuration

**Quick Start:**
1. Launch: `AutoHotkey.exe '/ErrorStdOut' scriptlets\mcp_server_scaffolding.ahk`
2. Enter project name and description
3. Select template (basic, advanced, file_ops, etc.)
4. Choose features and destination
5. Generate complete project

**Documentation**: See [MCP_Server_Scaffolding_Guide.md](MCP_Server_Scaffolding_Guide.md) for complete guide.

## 📝 Development Workflow

### 1. Creating New Scriptlets

1. **Create the scriptlet file** in `scriptlets/` directory
2. **Use proper AutoHotkey v2 syntax** (see migration guide)
3. **Add required directive**: `#Requires AutoHotkey v2.0`
4. **Test with linter**: Run `.\utils\run_linter_clean.ps1 -ScriptletPath 'your_file.ahk'`
5. **Fix any errors** found by the linter
6. **Validate functionality** with `utils/scriptlet_validator.ahk`

### 2. Modifying Existing Scriptlets

1. **Run linter first** to identify current issues
2. **Make your changes** using proper v2 syntax
3. **Re-run linter** to verify no new issues introduced
4. **Test functionality** to ensure changes work correctly
5. **Update documentation** if needed

### 3. Batch Operations

For large-scale changes:

1. **Run batch analysis**: `.\utils\batch_analyze_all.ps1`
2. **Review comprehensive report** in `docs/comprehensive_lint_report.txt`
3. **Apply automated fixes**: `.\utils\fix_autohotkey_errors.ps1`
4. **Verify improvements** with another batch analysis

## 🔧 Common AutoHotkey v2 Patterns

### Hotkey Syntax

**❌ Old (v1):**
```autohotkey
F1::SomeFunction()
^!c::ChessGame.Init()
```

**✅ New (v2):**
```autohotkey
Hotkey("F1", (*) => SomeFunction())
Hotkey("^!c", (*) => ChessGame.Init())
```

### File Operations

**❌ Old (v1):**
```autohotkey
FileRead(content, "file.txt")
FileDelete("temp.txt")
```

**✅ New (v2):**
```autohotkey
content := FileRead("file.txt")
try FileDelete("temp.txt")
```

### FormatTime

**❌ Old (v1):**
```autohotkey
FormatTime timestamp,, "yyyy-MM-dd HH:mm:ss"
```

**✅ New (v2):**
```autohotkey
timestamp := FormatTime(A_Now, "yyyy-MM-dd HH:mm:ss")
```

### MsgBox

**❌ Old (v1):**
```autohotkey
MsgBox "Hello", "Title", "OK"
```

**✅ New (v2):**
```autohotkey
MsgBox("Hello", "Title", "OK")
```

## 🚨 Error Categories

The linter identifies several categories of issues:

### Critical Errors (Must Fix)
- **Hotkey Syntax**: Incorrect `::` syntax
- **File Operations**: Wrong `FileRead`/`FileDelete` syntax
- **FormatTime**: Incorrect time formatting calls
- **Missing Directives**: Missing `#Requires AutoHotkey v2.0`

### Warnings (Should Fix)
- **Global Variables**: Consider using static/local variables
- **Missing Classes**: Consider class-based structure
- **Missing Init()**: Recommended for scriptlets

### Suggestions (Nice to Have)
- **Error Handling**: Add try/catch blocks
- **Code Organization**: Improve structure
- **Documentation**: Add comments

## 📊 Quality Metrics

### Current Status (v2.1.0)
- **Total Scriptlets**: 54
- **Files Modified**: 45
- **Errors Fixed**: 31
- **Remaining Errors**: 100
- **Files with Errors**: 16
- **Files with Warnings**: 26

### Target Metrics
- **Zero Critical Errors**: All syntax issues resolved
- **Minimal Warnings**: Only style-related warnings remain
- **100% v2 Compatibility**: All scriptlets use proper v2 syntax
- **Comprehensive Testing**: All scriptlets validated

## 🔍 Debugging

### Debug Tools

- **`scriptlets/autohotkey_debug_helper.ahk`** - Debug helper
  - `Ctrl+Alt+D` - View error logs
  - Variable inspection
  - Line-by-line debugging
  - Error tracking

- **`scriptlets/scriptlet_tester.ahk`** - Testing framework
  - `Ctrl+Alt+T` - Test all scriptlets
  - Syntax validation
  - Runtime testing
  - Performance monitoring

### Common Issues

1. **Process Conflicts**: Use `run_linter_clean.ps1` to kill old processes
2. **Syntax Errors**: Run linter to identify specific issues
3. **File Paths**: Ensure proper path handling in v2
4. **Hotkey Conflicts**: Use proper `Hotkey()` function syntax

## 📚 Resources

### Documentation
- `docs/AutoHotkey_v2_Syntax_Reference.md` - Complete syntax reference
- `docs/AutoHotkey_Debugging_Guide.md` - Debugging techniques
- `docs/autohotkey_errors_documented.md` - Error documentation

### External Resources
- [AutoHotkey v2 Documentation](https://www.autohotkey.com/docs/v2/)
- [Migration Guide](https://www.autohotkey.com/docs/v2/Scripts.htm#compatibility)
- [Syntax Changes](https://www.autohotkey.com/docs/v2/Scripts.htm#syntax-changes)

## 🤝 Contributing

### Pull Request Process

1. **Fork the repository**
2. **Create feature branch**: `git checkout -b feature/amazing-feature`
3. **Make changes** following development guidelines
4. **Run linting**: Ensure no new errors introduced
5. **Test functionality**: Verify changes work correctly
6. **Update documentation**: Update relevant docs
7. **Submit pull request**: Include description of changes

### Code Standards

- **Use AutoHotkey v2.0+ syntax exclusively**
- **Follow established patterns** from existing scriptlets
- **Include proper error handling** with try/catch blocks
- **Add comments** for complex logic
- **Test thoroughly** before submitting

### Commit Messages

Use clear, descriptive commit messages:

```
feat: add new chess game scriptlet
fix: resolve hotkey syntax error in clipboard manager
docs: update development guide with linting tools
refactor: convert remaining v1 syntax to v2
```

---

This development guide ensures consistent, high-quality development practices across the AutoHotkey Scriptlets Collection.
