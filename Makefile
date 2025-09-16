# Simple Packing - Makefile for testing and development

.PHONY: test test-verbose test-individual lint install-deps clean help

# Default target
help:
	@echo "Simple Packing - Available Make Targets:"
	@echo ""
	@echo "  test           - Run all unit tests"
	@echo "  test-verbose   - Run tests with verbose output"
	@echo "  test-individual - Run each test suite separately"
	@echo "  lint           - Run luacheck linting on source code"
	@echo "  install-deps   - Install required dependencies (luaunit, luacheck)"
	@echo "  clean          - Clean up generated files"
	@echo "  help           - Show this help message"
	@echo ""
	@echo "Requirements:"
	@echo "  - Lua 5.1+ installed"
	@echo "  - LuaRocks package manager"
	@echo ""
	@echo "First time setup:"
	@echo "  make install-deps"
	@echo "  make test"

# Install dependencies
install-deps:
	@echo "Installing Lua dependencies..."
	luarocks install luaunit
	luarocks install luacheck
	@echo "Dependencies installed successfully!"

# Run all tests
test:
	@echo "Running Simple Packing unit tests..."
	@echo "Project Zomboid B41 Compatible (Lua 5.1)"
	@echo "========================================"
	lua tests/run_tests.lua

# Run tests with verbose output
test-verbose:
	@echo "Running Simple Packing unit tests (verbose)..."
	LUA_PATH="./?.lua;./?/init.lua" lua -e "package.loaded.luaunit = require('luaunit'); luaunit.LuaUnit.verbosity = 2; dofile('tests/run_tests.lua')"

# Run each test suite individually
test-individual:
	@echo "Running individual test suites..."
	@echo ""
	@echo "1. Core Functions Tests:"
	lua tests/test_simple_functions.lua
	@echo ""
	@echo "2. Food Functions Tests:"
	lua tests/test_food_functions.lua
	@echo ""
	@echo "3. Rope/Container Functions Tests:"
	lua tests/test_rope_container_functions.lua
	@echo ""
	@echo "4. Merge/Split Functions Tests:"
	lua tests/test_merge_split_functions.lua
	@echo ""
	@echo "All individual test suites completed!"

# Run linting
lint:
	@echo "Running luacheck on source code..."
	@echo ""
	@echo "Checking simple_functions.lua:"
	luacheck Contents/mods/SimplePackingVanilla/media/lua/server/simple_functions.lua \
		--std=lua51 \
		--globals=Recipe Events ScriptManager print \
		--ignore=212 \
		--no-unused-args || true
	@echo ""
	@echo "Checking test files:"
	luacheck tests/ \
		--std=lua51 \
		--globals=luaunit Recipe Events ScriptManager print \
		--ignore=212 \
		--no-unused-args || true
	@echo ""
	@echo "Linting completed!"

# Run tests with coverage (if luacov is available)
test-coverage:
	@echo "Running tests with coverage analysis..."
	@if command -v luacov >/dev/null 2>&1; then \
		echo "Luacov found, running with coverage..."; \
		lua -lluacov tests/run_tests.lua; \
		luacov; \
		echo ""; \
		echo "Coverage Report:"; \
		echo "================"; \
		cat luacov.report.out; \
	else \
		echo "Luacov not installed, running tests without coverage..."; \
		echo "Install with: luarocks install luacov"; \
		lua tests/run_tests.lua; \
	fi

# Clean up generated files
clean:
	@echo "Cleaning up generated files..."
	rm -f luacov.stats.out
	rm -f luacov.report.out
	rm -f *.tmp
	@echo "Clean completed!"

# Quick development cycle
dev: clean test lint
	@echo ""
	@echo "Development cycle completed successfully!"
	@echo "✅ Tests passed"
	@echo "✅ Linting completed"

# Check system requirements
check-requirements:
	@echo "Checking system requirements..."
	@echo ""
	@echo -n "Lua: "
	@if command -v lua >/dev/null 2>&1; then \
		lua -v; \
	else \
		echo "❌ Not found. Please install Lua 5.1+"; \
	fi
	@echo -n "LuaRocks: "
	@if command -v luarocks >/dev/null 2>&1; then \
		luarocks --version | head -1; \
	else \
		echo "❌ Not found. Please install LuaRocks"; \
	fi
	@echo -n "LuaUnit: "
	@if lua -e "require('luaunit')" 2>/dev/null; then \
		echo "✅ Available"; \
	else \
		echo "❌ Not found. Run 'make install-deps'"; \
	fi
	@echo -n "LuaCheck: "
	@if command -v luacheck >/dev/null 2>&1; then \
		echo "✅ Available"; \
	else \
		echo "❌ Not found. Run 'make install-deps'"; \
	fi

# Continuous integration simulation
ci: check-requirements test lint
	@echo ""
	@echo "🎉 CI simulation completed successfully!"
	@echo "This simulates what will run in GitHub Actions"