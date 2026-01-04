# Copilot Instructions for EML Parser Module

## Project Overview
This is a PowerShell module that parses **EML files** (raw RFC 5322 Internet Message Format messages) and provides operations on email data. The module allows developers to read, analyze, and manipulate email message content programmatically.
Other than building and testing, this project should be entirely self-contained and not depend on any external libraries beyond standard PowerShell capabilities.
This project should be fully cross-platform compatible with Windows, Mac, and Linux systems running PowerShell 7.4 or later.

- **Language**: PowerShell 7.4+
- **Compatibility**: PowerShell Core and Desktop editions
- **Module Name**: Imf (Internet Message Format)
- **Version**: 0.0.1

## Architecture & Key Concepts

### Class Hierarchy
Classes are organized in numbered folders for proper load order (alphabetical sorting by `Build-Module`):
Classes may be further numbered within folders to ensure dependencies load first.

1. **01-Types** - Basic type definitions
  This used to have an Email class, but it has been removed in favor of using the built-in .NET type.
  If any other basic types are needed, they would go here.

2. **02-Header** - Header field and header collection classes
   - `01-HeaderField.ps1` - Abstract single header field representation
   - `01-HeaderFieldPlugins.ps1` - Plugin system (singleton class) for header parsing
   - `02-Headers.ps1` - Collection of header fields - this object holds all headers for an email message
   - `03-PluginHeader.ps1` - Base class for header plugins - extends HeaderField

3. **04-Email** - Main email message class
   - `Imf.ps1` - RFC 5322 compliant email message class.  This is the main entry point for public functions.

4. **05-Factories** - Factory classes for creating objects
   - `HeaderFieldFactory.ps1` - Creates appropriate HeaderField instances
   - `ImfFactory.ps1` - Creates email objects

5. **06-Plugins** - Plugin implementations for specific header types
   - `Headers/PluginHeaderGeneric.ps1` - Generic header parsing - used when no specific plugin exists
   - `Headers/PluginHeaderEmail.ps1` - Email-type headers (From, To, Cc, etc.)
   - `Headers/PluginHeaderList.ps1` - List-type headers
   - `Headers/PluginHeaderReceived.ps1` - Received header parsing

### Key Design Patterns

- **Plugin System**: Headers are parsed via plugins that report which header names they handle. The factory selects the appropriate plugin.
- **Factory Pattern**: `HeaderFieldFactory` and `ImfFactory` create typed objects
- **Fluent Interfaces**: Methods often return `$this` for method chaining
- **Getter/Setter Methods**: Classes use explicit `getName()`/`setName()` style methods

## Code Organization

```
EMLParser/
├── Classes/           # PowerShell class definitions
├── Public/            # Public module functions (Get-EmlInfo, Get-EmlObject)
├── Private/           # Internal helper functions
├── Enum/              # Enumeration definitions
├── Tests/             # Pester test suite
├── build/             # Build output folder (generated)
├── Imf.psd1          # Module manifest used by `Build-Module`
├── build.psd1        # Build configuration
└── makefile          # Unix make targets
```

## Important Notes for Implementation

### Build Order
**Classes load in alphabetical order by folder/file name.** If a class depends on another, prefix files with numbers to ensure correct order:
- ✅ Correct: `01-HeaderField.ps1`, `02-Headers.ps1`
- ❌ Wrong: `HeaderField.ps1`, `Headers.ps1` (may load in wrong order)

Parent classes must be numbered lower than child classes.

### RFC 5322 Compliance
The module implements RFC 5322 (Internet Message Format). Refer to parsing logic in header plugins for specification-compliant behavior.

## Building & Testing

### Build
```powershell
# Requires PoshCode ModuleBuilder
Build-Module  # Run in project root
```

Or on *NIX with `make`:
```bash
make
```

### Testing
```powershell
# Run all Pester tests
Invoke-Pester
```

Or on *NIX with `make`:
```bash
make test
```

Test files follow the pattern:
- `Tests/Private/` - Private class and helper tests
- `Tests/Public/` - Public function tests
- `*.NoTests.ps1` - Disabled tests
- `*.Tests.ps1` - Actual Pester test files

## Code Style Guidelines

### PowerShell Class Conventions
- Use `[Type]` for explicit type declarations
- Implement constructors that accept parameters
- Use getter/setter methods: `getName()`, `setName()`
- Return `$this` from setters for method chaining
- Document with comment-based help (`.SYNOPSIS`, `.DESCRIPTION`, `.PARAMETER`, `.OUTPUTS`)

### Naming Conventions
- **Classes**: PascalCase (e.g., `HeaderField`, `ImfFactory`)
- **Methods**: camelCase (e.g., `getName()`, `setName()`)
- **Properties**: PascalCase (e.g., `$this.Name`, `$this.Body`)
- **Functions**: Verb-Noun (e.g., `Get-EmlInfo`, `Get-EmlObject`)

### File Organization
- Prefix class files with numbers if load order matters
- Keep related classes in same folder
- Use descriptive README.md files in class folders

## Common Tasks

### Adding a New Header Type
1. Create plugin class in `Classes/06-Plugins/Headers/PluginHeader[Type].ps1`
2. Extend `PluginHeader` base class
3. Implement header-specific parsing logic
4. Register plugin in factory by calling `[HeaderFieldPlugins]::GetInstance().RegisterPlugin([PluginHeader[Type]])`


### Adding a New Class
1. Create file in appropriate numbered folder under `Classes/`
2. If it needs to load before other classes, prefix with lower number
3. Add Pester tests in `Tests/Private/` with `.Tests.ps1` suffix
4. Run `Build-Module` to regenerate `Imf.psm1`

### Testing
- Use Pester framework (`Describe`, `Context`, `It`)
- Tests located parallel to source in `Tests/` folder
- Filename pattern: `ClassName.Tests.ps1`

## References
- [RFC 5322 - Internet Message Format](https://www.rfc-editor.org/rfc/rfc5322.html)
- [PoshCode ModuleBuilder](https://github.com/PoshCode/ModuleBuilder)
- [Pester Testing Framework](https://pester.dev/)
- [PowerShell 7 Classes](https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_classes)

## Project TODOs
- Enhance plugin system for more robust header handling
- Expand test coverage for all classes
- Add email message manipulation features
