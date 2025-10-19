#!/usr/bin/env bash
# OpenSCAD setup and configuration script
# Sets up OpenSCAD with VS Code integration for 3D modeling

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/../.." && pwd)"

# shellcheck source=../../lib/bash/common.sh
# shellcheck disable=SC1091
source "${REPO_ROOT}/lib/bash/common.sh"

# Additional logging functions
log_success() {
  printf "\033[1;32m[%s] %s\033[0m\n" "${LOG_TAG}" "$*"
}

log_section() {
  printf "\n\033[1;36m==> %s\033[0m\n" "$*"
}

# TODO - re-use whatever is in @common.sh
# Color codes for summary
BOLD=$'\033[1m'
GREEN=$'\033[1;32m'
NC=$'\033[0m'

# Configuration
OPENSCAD_APP="/Applications/OpenSCAD-2021.01.app" # TODO: should this be discovered w/ a brew command?
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
  --install-extensions    Install recommended VS Code extensions
  --test                  Run a test render after setup
  --skip-config          Skip VS Code configuration (only verify installation)

EXAMPLES:
  $(basename "$0")                          # Basic setup and configuration
  $(basename "$0") --install-extensions     # Setup and install extensions
  $(basename "$0") --test                   # Setup and test with sample file

PREREQUISITES:
  - OpenSCAD installed via Homebrew (brew install --cask openscad)
  - VS Code installed
  - Rosetta 2 (for Apple Silicon Macs)

EOF
}

# TODO - This should be using system checks in @common.sh.  Extend them as needed to support this functionality
check_rosetta() {
  log_info "Checking Rosetta 2 installation..."

  # TODO - we'll only ever be on silocon macs, do not test architecture
  if [[ "$(uname -m)" == "arm64" ]]; then
    if ! pgrep -q oahd; then
      log_warn "Rosetta 2 may not be installed. OpenSCAD requires Rosetta 2 on Apple Silicon."
      log_info "Install with: softwareupdate --install-rosetta --agree-to-license"
      return 1
    else
      log_success "Rosetta 2 is installed"
    fi
  fi
}

verify_openscad() {
  log_info "Verifying OpenSCAD installation..."

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

${BOLD}${GREEN}OpenSCAD Setup Complete!${NC}

${BOLD}Installed Components:${NC}
  - OpenSCAD: $(openscad --version 2>&1 | head -1)
  - Command-line tool: $(which openscad)
  - VS Code extensions: $(code --list-extensions | grep -i openscad | tr '\n' ', ' | sed 's/,$//')

${BOLD}VS Code Usage:${NC}
  1. Open any .scad file in VS Code
  2. Click 'Preview in OpenSCAD' button (top right)
  3. Edit and save - preview auto-reloads
  4. Click 'Export Model' to export to STL, 3MF, etc.

${BOLD}Command-line Usage:${NC}
  # Render to STL
  openscad -o output.stl input.scad

  # Render to PNG (with camera)
  openscad -o output.png --camera=0,0,0,55,0,25,140 input.scad

  # With parameters
  openscad -o output.stl -D 'width=50' -D 'height=100' input.scad

${BOLD}Useful Resources:${NC}
  - OpenSCAD Cheatsheet: https://openscad.org/cheatsheet/
  - Tutorial: https://openscad.org/documentation.html
  - VS Code Extension Docs: https://marketplace.visualstudio.com/items?itemName=Antyos.openscad

EOF
}

# TODO this also needs to actually install openscad and rosetta as needed
main() {
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

  log_section "OpenSCAD Setup"

  # Verify installation (will exit on failure)
  verify_openscad

  # Check Rosetta 2
  check_rosetta || true

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
