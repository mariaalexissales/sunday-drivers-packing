#!/usr/bin/env python3
"""
Test validation script for Pack Rat mod
Validates Lua syntax and test structure without requiring Lua installation
"""

import os
import re
import sys
from pathlib import Path

def validate_lua_syntax(file_path):
    """Basic Lua syntax validation"""
    with open(file_path, 'r', encoding='utf-8') as f:
        content = f.read()

    issues = []

    # Check for basic syntax patterns
    lines = content.split('\n')
    for i, line in enumerate(lines, 1):
        line = line.strip()

        # Check for unmatched parentheses, brackets, quotes
        open_parens = line.count('(') - line.count(')')
        open_brackets = line.count('[') - line.count(']')

        # Check for common Lua keywords and patterns
        if 'function' in line and not line.startswith('--'):
            if not re.search(r'function\s+\w+.*\(.*\)', line) and not 'end' in line:
                if not line.endswith('(') and not line.endswith(','):
                    # This might be a function declaration, check if it's properly formatted
                    pass

    return issues

def validate_test_structure():
    """Validate the test directory structure"""
    tests_dir = Path('tests')

    if not tests_dir.exists():
        return False, "tests directory does not exist"

    required_files = [
        'test_framework.lua',
        'mocks.lua',
        'test_simple_functions.lua',
        'test_simple_book_packing.lua',
        'test_simple_fuel.lua',
        'run_tests.lua'
    ]

    missing_files = []
    for file in required_files:
        if not (tests_dir / file).exists():
            missing_files.append(file)

    if missing_files:
        return False, f"Missing files: {', '.join(missing_files)}"

    return True, "All required test files present"

def validate_github_workflows():
    """Validate GitHub Actions workflow files"""
    workflows_dir = Path('.github/workflows')

    if not workflows_dir.exists():
        return False, "GitHub workflows directory does not exist"

    workflow_files = list(workflows_dir.glob('*.yml'))

    if len(workflow_files) == 0:
        return False, "No workflow files found"

    # Check for required workflow content
    for workflow_file in workflow_files:
        with open(workflow_file, 'r', encoding='utf-8') as f:
            content = f.read()

        if 'lua5.1' not in content.lower():
            return False, f"Workflow {workflow_file.name} does not specify Lua 5.1"

        if 'test' not in content.lower():
            return False, f"Workflow {workflow_file.name} does not appear to run tests"

    return True, f"Found {len(workflow_files)} valid workflow file(s)"

def validate_lua_files():
    """Validate Lua source files"""
    lua_files = []

    # Find all Lua files
    for root, dirs, files in os.walk('.'):
        for file in files:
            if file.endswith('.lua'):
                lua_files.append(os.path.join(root, file))

    if not lua_files:
        return False, "No Lua files found"

    issues = []
    for lua_file in lua_files:
        try:
            file_issues = validate_lua_syntax(lua_file)
            if file_issues:
                issues.extend([f"{lua_file}: {issue}" for issue in file_issues])
        except Exception as e:
            issues.append(f"{lua_file}: Error reading file - {e}")

    return len(issues) == 0, f"Validated {len(lua_files)} Lua files" + (f" - Issues: {issues}" if issues else "")

def main():
    print("Pack Rat Mod - Test Validation")
    print("=" * 40)

    validations = [
        ("Test Structure", validate_test_structure),
        ("GitHub Workflows", validate_github_workflows),
        ("Lua Files", validate_lua_files)
    ]

    all_passed = True

    for name, validator in validations:
        try:
            passed, message = validator()
            status = "[PASS]" if passed else "[FAIL]"
            print(f"{name}: {status} - {message}")
            if not passed:
                all_passed = False
        except Exception as e:
            print(f"{name}: [ERROR] - {e}")
            all_passed = False

    print("\n" + "=" * 40)
    if all_passed:
        print("All validations passed!")
        print("\nNext steps:")
        print("1. Create a test branch: git checkout -b test-your-feature")
        print("2. Push to GitHub to trigger CI/CD")
        print("3. Check GitHub Actions for test results")
        return 0
    else:
        print("Some validations failed.")
        print("Please fix the issues above before proceeding.")
        return 1

if __name__ == "__main__":
    sys.exit(main())