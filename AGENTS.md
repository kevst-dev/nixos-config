# AGENTS.md

This file contains guidelines and commands for agentic coding agents working in this NixOS configuration repository.

## Build Commands

This repository uses `just` as the task runner. Essential commands:

### Core Commands
- `just` - Show all available commands
- `just wsl` - Deploy to WSL host (builds and switches configuration)
- `just turing` - Deploy to Turing server
- `just deploy` - Deploy to current machine (has issues, use host-specific commands)

### Development Commands
- `just check` - Run all quality checks (linting, formatting, pre-commit hooks)
- `just dev` - Enter development environment with all tools available
- `just update` - Update flake inputs and deploy configuration
- `just debug` - Deploy with verbose output and stack traces

### Testing Commands
- `just test-unit-all` - Run all unit tests using NixOS VM tests
- `just test-unit <test-name>` - Run specific test (e.g., `just test-unit test-git`)
- `just test-unit-list` - List available unit tests
- `just test-integration-all` - Run all integration tests
- `just test-integration-turing` - Run Turing integration test
- `just test-integration-list` - List available integration tests

### Available Tests
Unit tests: `test-git`, `test-starship`, `test-zsh`, `test-zoxide`, `test-common`, `test-neovim`
Integration tests: `test-turing`

## Code Style Guidelines

### Nix Files (.nix)

#### Imports and Structure
- Use function pattern: `{pkgs, ...}: {` at file start
- Import modules with `imports = [ ./path/to/file.nix ];`
- Use `lib.recursiveUpdate` for merging nested attribute sets
- Follow modular structure: separate concerns into different files

#### Formatting
- Use Alejandra formatter (automatically applied via pre-commit hooks)
- Indentation: 2 spaces (Alejandra standard)
- Line length: No strict limit, but prefer readability
- Use trailing commas in lists and attribute sets

#### Naming Conventions
- Files: kebab-case (e.g., `starship.nix`, `neovim/default.nix`)
- Variables: camelCase for local variables, kebab-case for top-level attributes
- Functions: descriptive names, avoid abbreviations

#### Attributes and Options
- Group related options together
- Use `with pkgs;` for package lists when appropriate
- Comment complex configurations with Spanish comments (following repository style)
- Use `inherit` for passing through attributes

#### Error Handling
- Use `lib.mkIf` for conditional configuration
- Provide meaningful error messages in assertions
- Use `lib.optional` for conditional list elements

### Lua Files (.lua)

#### Imports and Structure
- Use `local` for all variables and functions
- Group imports at file top: `local plugin = require("plugin")`
- Use module pattern: `local M = {} ... return M`

#### Formatting
- Use StyLua formatter (automatically applied via pre-commit hooks)
- Indentation: 2 spaces
- No trailing whitespace
- Use semicolons sparingly (Lua style)

#### Naming Conventions
- Variables: snake_case (e.g., `local config_options`)
- Functions: snake_case or descriptive verbs
- Constants: UPPER_SNAKE_CASE
- Modules: kebab-case for filenames

#### Vim/Neovim Specific
- Use `vim.g` for global variables
- Use `vim.opt` for options (preferred over `vim.o`)
- Use `vim.keymap.set` for keybindings
- Prefer `vim.api` over `vim.fn` when possible

### Shell Scripts (.sh, .bash, .zsh)

#### Formatting
- Use shfmt formatter (automatically applied via pre-commit hooks)
- Use ShellCheck for linting
- Indentation: 2 spaces
- Quote variables: `"$VAR"` not `$VAR`

#### Naming
- Functions: snake_case
- Variables: UPPER_SNAKE_CASE for constants, snake_case for variables
- Use `local` for function-scoped variables

## Repository Structure

### Configuration Layers
1. **System level** (`modules/system.nix`): Core system packages and settings
2. **Host level** (`hosts/{hostname}/default.nix`): Host-specific settings
3. **User level** (`users/{username}/home.nix`): User-specific imports
4. **Home Manager modules** (`home/programs/`): Modular program configurations
5. **Dotfiles** (`dotfiles/`): Raw configuration files for Neovim and Zsh

### File Organization
- Keep related configurations in the same directory
- Use `default.nix` for module entry points
- Separate concerns: one program per file in `home/programs/`
- Test files mirror structure with `tests-` prefix

## Development Workflow

### Pre-commit Hooks
The repository uses comprehensive pre-commit hooks via `dev/flake.nix`:
- **Nix**: Alejandra (formatter), Statix (linter), Deadnix (dead code removal)
- **Lua**: StyLua (formatter), lua-language-server (linter)
- **Shell**: shfmt (formatter), ShellCheck (linter)
- **General**: YAML validation, merge conflict detection, large file detection

### Testing Strategy
- **Unit tests**: Individual component testing in isolated NixOS VMs
- **Integration tests**: Full system testing for complete configurations
- All tests use `pkgs.testers.runNixOSTest` for consistency
- Tests verify both installation and configuration correctness

### Quality Assurance
- Always run `just check` before committing
- Use `just test-unit-all` to verify changes don't break existing functionality
- Test on target host when possible (WSL/Turing)
- Follow Spanish commenting style for consistency with existing code

## Common Patterns

### Home Manager Module Pattern
```nix
{pkgs, ...}: {
  home.packages = with pkgs; [package1 package2];
  programs.programName = {
    enable = true;
    settings = {
      # configuration
    };
  };
}
```

### Flake Host Pattern
```nix
mkHost {
  hostname = "example";
  userConfig = ./users/kevst/example.nix;
  includeWSL = false; # or true for WSL
};
```

### Test Pattern
```nix
{home-manager}: {
  name = "Test description";
  nodes = {
    machine = {pkgs, ...}: {
      # test configuration
    };
  };
  testScript = ''
    # test steps
  '';
}
```

## Special Considerations

### WSL Integration
- WSL-specific configurations use `includeWSL = true`
- Clipboard integration configured for win32yank-wsl
- Path handling considers Windows/WSL differences

### Neovim Configuration
- Uses nixCats framework for modular configuration
- Lua files are symlinked, not bundled (for rapid iteration)
- Categories defined in separate modules (ui.nix, syntax.nix)
- Session management configured to avoid directory issues

### Multi-host Support
- Single user ("kevst") across all hosts
- Host-specific configurations in separate directories
- Shared modules for common configurations
- Flake-based deployment for consistency