# Run tests for Neovim configuration
.PHONY: test

test:
	nvim --clean --headless -u tests/minimal_init.lua -c "PlenaryBustedDirectory tests/utils {minimal_init = 'tests/minimal_init.lua'}"
