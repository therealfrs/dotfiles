# Developer & Agent Guide: Neovim Configuration

Welcome! This document serves as an onboarding guide for developers and AI assistants (agents) working on this Neovim configuration. It outlines the architecture, custom utilities, plugin ecosystem, and testing workflows.

---

## 📂 Repository Structure

```
nvim/
├── init.lua              # Main entry point (loads basics, custom utils, and lazy.nvim)
├── basics.vim            # Legacy/basic Vim settings (sourced by init.lua)
├── google.vim            # Google-specific Vim settings (sourced by init.lua)
├── Makefile              # Automation tasks (e.g., running tests)
├── AGENT.md              # This document
├── lua/
│   ├── config/
│   │   └── lazy.lua      # Plugin management & configuration (lazy.nvim)
│   ├── utils/
│   │   ├── file_type.lua # Filetype-specific autocommands
│   │   └── ninja_build.lua# Custom Ninja build integration
│   └── windows.lua       # Custom window management helpers
└── tests/                # Test suite
    ├── minimal_init.lua  # Bootstraps isolated headless Neovim for testing
    └── utils/
        └── ninja_build_spec.lua # Tests for ninja_build.lua
```

---

## 🛠️ Custom Utilities & Features

These are custom Lua modules written specifically for this configuration, located in `lua/`.

### 1. Ninja Build Integration (`lua/utils/ninja_build.lua`)
Provides a seamless way to run Ninja builds in a subdirectory and automatically fix the resulting compiler paths in the quickfix list so you can jump directly to errors.

*   **Commands**:
    *   `:NinjaBuild <path> [target]` (e.g., `:NinjaBuild out/Debug chrome`)
*   **Key Features**:
    *   Dynamically updates `makeprg` to use `autoninja`.
    *   Registers `QuickFixCmdPost` autocommands to intercept build results.
    *   Adjusts relative paths in the quickfix list to be relative to the build directory.
    *   Resets state safely after the build to prevent polluting subsequent non-ninja builds.

### 2. Filetype Configurations (`lua/utils/file_type.lua`)
Automates buffer-local settings based on the file type.
*   **Markdown**: Enables spell checking (`spell = true`).
*   **Git Commit**: Sets text width to 72 characters, highlights the color column at 72, and enables spell checking.

### 3. Window Management (`lua/windows.lua`)
Provides smart window splitting and closing helpers.
*   `split_nicely()`: Automatically decides whether to split vertically or horizontally based on the current window width (prefers vertical if space permits).
*   `smart_close()`: Closes the current window, but prevents closing if it is the last remaining window.

---

## 🔌 Plugin Ecosystem

Plugins are managed via **[lazy.nvim](file:///usr/local/google/home/frs/git/dotfiles/nvim/lua/config/lazy.lua)**. Key plugins include:

*   **Fuzzy Finding**: `telescope.nvim` and `fzf` for fast file and text searching.
*   **Syntax Highlighting**: `nvim-treesitter` for advanced language parsing.
*   **Completion**: `blink.cmp` (modern, fast completion engine).
*   **LSP**: `nvim-lspconfig` configured for `clangd` (C++), `pylsp` (Python), `taplo` (TOML), `gopls` (Go), and `tsserver` (TypeScript).
*   **UI**: `lualine.nvim` (statusline, using the `alabaster` theme), `which-key.nvim` (keymap visualizer), and `render-markdown.nvim`.

---

## 🧪 Testing Framework

We use **`plenary.nvim`**'s built-in Busted test harness to run unit and integration tests inside an isolated, headless Neovim instance.

### Running Tests
To run the entire test suite, run the following command from the `nvim/` directory:

```bash
make test
```

This executes:
```bash
nvim --clean --headless -u tests/minimal_init.lua -c "PlenaryBustedDirectory tests/utils"
```
*   `--clean`: Isolates tests from your active Neovim session and configuration errors.
*   `-u tests/minimal_init.lua`: Bootstraps the testing environment (loads Plenary and registers local paths).

### Writing New Tests
1.  Place test files in the `tests/` directory, ending in `_spec.lua` (e.g., `tests/utils/my_feature_spec.lua`).
2.  Use Busted's BDD-style syntax:
    ```lua
    describe("my_feature", function()
      it("performs as expected", function()
        local result = require('my_module').do_something()
        assert.are.equal("expected_value", result)
      end)
    end)
    ```

---

## 🤖 Guidelines for AI Agents

When modifying this repository, please adhere to the following rules:

1.  **Test Before Completing**: Always run `make test` before declaring a task finished. Ensure no regressions are introduced.
2.  **Isolate Utilities**: Keep custom editor logic in `lua/utils/` or standalone modules. Do not bloat `init.lua`.
3.  **Maintain Test Coverage**: If you add new custom helper functions or modify existing ones, write corresponding tests in `tests/`.
4.  **Preserve Configuration Style**: Maintain the clean, modular Lua structure. Prefer standard Neovim Lua APIs (`vim.api.*`) over legacy Vimscript wraps where possible.
