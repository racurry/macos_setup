# Software Development Tools

This document catalogs all tools, applications, and configurations specifically used for software development workflows in this repository. For general-purpose applications and utilities, see [README.md](README.md).

## Table of Contents

- [IDEs & Editors](#ides--editors)
- [Terminal & Shell](#terminal--shell)
- [Version Control](#version-control)
- [Package & Runtime Management](#package--runtime-management)
- [AI Coding Assistants](#ai-coding-assistants)
- [Code Quality & Linting](#code-quality--linting)
- [Container & Virtualization](#container--virtualization)
- [Runtime Environments](#runtime-environments)

---

## IDEs & Editors

- **cursor** - AI-powered code editor with inline AI assistance
- **visual-studio-code** - Microsoft's extensible code editor
  - Extensions managed via Brewfile
  - Config: VS Code extensions listed below
- **xcode** - Apple's IDE for macOS/iOS/Swift development (Mac App Store)

---

## Terminal & Shell

- **iterm2** - Advanced terminal emulator with split panes and search
  - Config: [`apps/iterm2/README.md`](../apps/iterm2/README.md)
- **zsh** - Modern shell with enhanced features and better scripting
  - Config: [`apps/zsh/.zshrc`](../apps/zsh/.zshrc)
- **zsh-autosuggestions** - Fish-like command autosuggestions based on history
- **zsh-syntax-highlighting** - Real-time syntax highlighting for shell commands
- **pure** - Minimal and fast zsh prompt with git status

---

## Version Control

- **git** - Distributed version control system
  - Config: [`apps/git/.gitconfig`](../apps/git/.gitconfig)
- **gh** - GitHub's official CLI for issues, PRs, and workflows
- **hub** - GitHub wrapper adding extra git commands for GitHub operations
- **diff-so-fancy** - Enhanced git diff with improved readability and syntax highlighting

---

## Package & Runtime Management

- **asdf** - Multi-language version manager for nodejs, python, ruby, and more
  - Config: [`apps/asdf/.tool-versions`](../apps/asdf/.tool-versions)
  - Setup: [`apps/asdf/asdf.sh`](../apps/asdf/asdf.sh)
- **uv** - Fast Python package installer and resolver written in Rust
- **yarn** - JavaScript package manager with workspace support

---

## AI Coding Assistants

- **gemini-cli** - Google Gemini AI CLI for code assistance and generation
- **claude-code** - Anthropic's official Claude CLI for software engineering
  - Config: [`apps/claudecode/`](../apps/claudecode/)
  - Setup: [`apps/claudecode/claudecode.sh`](../apps/claudecode/claudecode.sh)

---

## Code Quality & Linting

- **shellcheck** - Static analysis tool for shell scripts (bash/sh)
- **markdownlint-cli2** - Markdown linting and style checker
- **yamllint** - YAML file linting and validation tool
- **ruff** - Extremely fast Python linter and formatter replacing flake8/black
- **bats-core** - Bash Automated Testing System for shell script testing

---

## Container & Virtualization

- **docker-desktop** - Container development platform with Docker and Kubernetes

---

## Runtime Environments

Managed via [`asdf`](https://asdf-vm.com/) and defined in [`apps/asdf/.tool-versions`](../apps/asdf/.tool-versions):

- **Python 3.11.6** - Default Python runtime for development
  - Global packages: [`apps/asdf/.default-python-packages`](../apps/asdf/.default-python-packages)
  - Config: [`apps/ruff/ruff.toml`](../apps/ruff/ruff.toml)
- **Ruby 3.4.4** - Default Ruby runtime
  - Global gems: [`apps/asdf/.default-gems`](../apps/asdf/.default-gems)
- **Node.js 24.1.0** - Default Node runtime for JavaScript development
  - Global packages: [`apps/asdf/.default-npm-packages`](../apps/asdf/.default-npm-packages)
  - Includes: `@anthropic-ai/claude-code`, `whic`

### Environment Management

- **direnv** - Per-directory environment variable management
  - Config: [`apps/zsh/.galileorc`](../apps/zsh/.galileorc)
  - Setup: [`apps/direnv/direnv.sh`](../apps/direnv/direnv.sh)
