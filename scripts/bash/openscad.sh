#!/usr/bin/env bash
# OpenSCAD setup and configuration script
# Sets up OpenSCAD with VS Code integration for 3D modeling

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/../.." && pwd)"

# shellcheck source=../../lib/bash/common.sh
# shellcheck disable=SC1091
source "${REPO_ROOT}/lib/bash/common.sh"

# Configuration - Discover OpenSCAD installation
discover_openscad_app() {
  # Find OpenSCAD app in /Applications (handles any version)
  local app
  app=$(find /Applications -maxdepth 1 -name "OpenSCAD*.app" -print -quit 2>/dev/null)
  if [[ -z "${app}" ]]; then
    return 1
  fi
  echo "${app}"
}

OPENSCAD_APP=$(discover_openscad_app)
OPENSCAD_BINARY="${OPENSCAD_APP}/Contents/MacOS/OpenSCAD"
VSCODE_SETTINGS="$HOME/Library/Application Support/Code/User/settings.json"
RECOMMENDED_EXTENSIONS=(
  "antyos.openscad"                          # Syntax highlighting, preview in external OpenSCAD
  "Leathong.openscad-language-support"       # Language server with inline preview
)

show_help() {
  cat << EOF
Usage: $(basename "$0") [OPTIONS]

Set up OpenSCAD with VS Code integration for 3D modeling.

This script:
  - Verifies OpenSCAD installation
  - Configures VS Code extensions for OpenSCAD
  - Sets up proper paths in VS Code settings
  - Optionally installs recommended VS Code extensions
  - Tests the setup

OPTIONS:
  -h, --help              Show this help message and exit
  --install               Install OpenSCAD and Rosetta 2 if not present
  --install-extensions    Install recommended VS Code extensions
  --test                  Run a test render after setup
  --skip-config           Skip VS Code configuration (only verify installation)

EXAMPLES:
  $(basename "$0")                          # Basic setup and configuration
  $(basename "$0") --install                # Install OpenSCAD and Rosetta 2, then configure
  $(basename "$0") --install-extensions     # Setup and install VS Code extensions
  $(basename "$0") --test                   # Setup and test with sample file

PREREQUISITES:
  - Homebrew installed
  - VS Code installed (for VS Code integration)

NOTE:
  - Without --install flag, OpenSCAD and Rosetta 2 must be pre-installed
  - Use --install to automatically install OpenSCAD and Rosetta 2

EOF
}

install_rosetta() {
  log_info "Installing Rosetta 2..."

  if check_rosetta; then
    log_success "Rosetta 2 is already installed"
    return 0
  fi

  log_info "Installing Rosetta 2 (this may take a few minutes)..."
  if softwareupdate --install-rosetta --agree-to-license; then
    log_success "Rosetta 2 installed successfully"
  else
    log_error "Failed to install Rosetta 2"
    return 1
  fi
}

verify_rosetta() {
  log_info "Checking Rosetta 2 installation..."

  if check_rosetta; then
    log_success "Rosetta 2 is installed"
  else
    log_warn "Rosetta 2 is not installed. OpenSCAD requires Rosetta 2 on Apple Silicon."
    log_info "Install with: softwareupdate --install-rosetta --agree-to-license"
    return 1
  fi
}

install_openscad() {
  log_info "Installing OpenSCAD..."

  require_command brew

  if brew list --cask openscad &>/dev/null; then
    log_success "OpenSCAD is already installed"
    return 0
  fi

  log_info "Installing OpenSCAD via Homebrew..."
  if brew install --cask openscad; then
    log_success "OpenSCAD installed successfully"

    # Re-discover the app path after installation
    OPENSCAD_APP=$(discover_openscad_app)
    OPENSCAD_BINARY="${OPENSCAD_APP}/Contents/MacOS/OpenSCAD"
  else
    log_error "Failed to install OpenSCAD"
    return 1
  fi
}

verify_openscad() {
  log_info "Verifying OpenSCAD installation..."

  if [[ -z "${OPENSCAD_APP}" ]]; then
    log_error "OpenSCAD not found in /Applications"
    log_info "Install with: brew install --cask openscad"
    fail "OpenSCAD installation required"
  fi

  require_directory "${OPENSCAD_APP}"
  require_file "${OPENSCAD_BINARY}"
  require_command openscad

  local version
  version=$(openscad --version 2>&1 | head -1)
  log_success "OpenSCAD found: ${version}"
}

check_vscode_extension() {
  local ext_id="$1"
  code --list-extensions | grep -q "^${ext_id}$"
}

install_extensions() {
  log_info "Installing recommended VS Code extensions..."

  for ext in "${RECOMMENDED_EXTENSIONS[@]}"; do
    if check_vscode_extension "${ext}"; then
      log_success "Extension already installed: ${ext}"
    else
      log_info "Installing extension: ${ext}"
      if code --install-extension "${ext}" &> /dev/null; then
        log_success "Installed: ${ext}"
      else
        log_warn "Failed to install: ${ext}"
      fi
    fi
  done
}

configure_vscode() {
  log_info "Configuring VS Code settings for OpenSCAD..."

  local update_script="${REPO_ROOT}/scripts/python/update_vscode_settings.py"

  if "${update_script}" "${VSCODE_SETTINGS}" "${OPENSCAD_BINARY}"; then
    log_success "VS Code settings configured"
  else
    log_error "Failed to update VS Code settings"
    return 1
  fi

  log_info "Configuration added:"
  log_info "  - openscad.launchPath: ${OPENSCAD_BINARY}"
  log_info "  - scad-lsp.launchPath: ${OPENSCAD_BINARY}"
  log_info "  - scad-lsp.inlinePreview: true"
}

test_setup() {
  log_info "Testing OpenSCAD setup..."

  local example_file="${REPO_ROOT}/apps/openscad/example.scad"
  local test_dir
  test_dir=$(mktemp -d)
  local output_file="${test_dir}/test.stl"

  # Verify example file exists
  require_file "${example_file}"

  # Test command-line rendering
  log_info "Testing command-line rendering with example file..."
  if openscad -o "${output_file}" "${example_file}" 2>&1; then
    if [[ -f "${output_file}" ]]; then
      log_success "Command-line rendering works!"
      log_info "Rendered: ${output_file}"
      ls -lh "${output_file}"
    else
      log_error "Rendering completed but output file not created"
      rm -rf "${test_dir}"
      return 1
    fi
  else
    log_error "Command-line rendering failed"
    rm -rf "${test_dir}"
    return 1
  fi

  # Optionally open in VS Code
  log_info "To test VS Code integration:"
  log_info "  1. Open: code ${example_file}"
  log_info "  2. Click 'Preview in OpenSCAD' button (top right)"
  log_info "  3. Edit parameters and save - preview auto-reloads"

  echo ""
  read -p "Open example file in VS Code now? (y/n) " -n 1 -r
  echo
  if [[ $REPLY =~ ^[Yy]$ ]]; then
    code "${example_file}"
  fi

  # Clean up
  rm -rf "${test_dir}"
}

print_summary() {
  cat << EOF

${CLR_BOLD}${CLR_SUCCESS}OpenSCAD Setup Complete!${CLR_RESET}

${CLR_BOLD}Installed Components:${CLR_RESET}
  - OpenSCAD: $(openscad --version 2>&1 | head -1)
  - Command-line tool: $(which openscad)
  - VS Code extensions: $(code --list-extensions | grep -i openscad | tr '\n' ', ' | sed 's/,$//')

${CLR_BOLD}VS Code Usage:${CLR_RESET}
  1. Open any .scad file in VS Code
  2. Click 'Preview in OpenSCAD' button (top right)
  3. Edit and save - preview auto-reloads
  4. Click 'Export Model' to export to STL, 3MF, etc.

${CLR_BOLD}Command-line Usage:${CLR_RESET}
  # Render to STL
  openscad -o output.stl input.scad

  # Render to PNG (with camera)
  openscad -o output.png --camera=0,0,0,55,0,25,140 input.scad

  # With parameters
  openscad -o output.stl -D 'width=50' -D 'height=100' input.scad

${CLR_BOLD}Useful Resources:${CLR_RESET}
  - OpenSCAD Cheatsheet: https://openscad.org/cheatsheet/
  - Tutorial: https://openscad.org/documentation.html
  - VS Code Extension Docs: https://marketplace.visualstudio.com/items?itemName=Antyos.openscad

EOF
}

main() {
  local do_install=false
  local install_exts=false
  local run_test=false
  local skip_config=false

  # Parse arguments
  while [[ $# -gt 0 ]]; do
    case $1 in
      -h|--help)
        show_help
        exit 0
        ;;
      --install)
        do_install=true
        shift
        ;;
      --install-extensions)
        install_exts=true
        shift
        ;;
      --test)
        run_test=true
        shift
        ;;
      --skip-config)
        skip_config=true
        shift
        ;;
      *)
        log_error "Unknown option: $1"
        show_help
        exit 1
        ;;
    esac
  done

  print_heading "OpenSCAD Setup"

  # Install if requested
  if [[ "${do_install}" == true ]]; then
    install_rosetta
    install_openscad
  fi

  # Verify installation (will exit on failure)
  verify_openscad

  # Check Rosetta 2
  verify_rosetta || true

  # Install extensions if requested
  if [[ "${install_exts}" == true ]]; then
    install_extensions
  fi

  # Configure VS Code
  if [[ "${skip_config}" == false ]]; then
    if ! configure_vscode; then
      log_error "VS Code configuration failed"
      exit 1
    fi
  fi

  # Run test if requested
  if [[ "${run_test}" == true ]]; then
    test_setup
  fi

  # Print summary
  print_summary

  log_success "OpenSCAD setup complete!"
}

main "$@"
