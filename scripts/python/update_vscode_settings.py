#!/usr/bin/env python3
"""Update VS Code settings.json with OpenSCAD configuration."""

import argparse
import json
import sys
from pathlib import Path


def update_settings(settings_file: Path, openscad_path: str) -> None:
    """Update VS Code settings with OpenSCAD configuration."""
    # Ensure parent directory exists
    settings_file.parent.mkdir(parents=True, exist_ok=True)

    # Read existing settings or create new
    if settings_file.exists():
        with open(settings_file, "r", encoding="utf-8") as f:
            settings = json.load(f)
    else:
        settings = {}

    # Update OpenSCAD settings
    settings["openscad.launchPath"] = openscad_path
    settings["scad-lsp.launchPath"] = openscad_path

    # Optional: Set up inline preview (if not already set)
    if "scad-lsp.inlinePreview" not in settings:
        settings["scad-lsp.inlinePreview"] = True

    # Write back
    with open(settings_file, "w", encoding="utf-8") as f:
        json.dump(settings, f, indent=2)
        f.write("\n")  # Add trailing newline


def main():
    parser = argparse.ArgumentParser(
        description="Update VS Code settings.json with OpenSCAD configuration"
    )
    parser.add_argument(
        "settings_file",
        type=Path,
        help="Path to VS Code settings.json file",
    )
    parser.add_argument(
        "openscad_path",
        help="Path to OpenSCAD binary",
    )

    args = parser.parse_args()

    try:
        update_settings(args.settings_file, args.openscad_path)
        print("VS Code settings updated successfully")
    except Exception as e:
        print(f"ERROR: {e}", file=sys.stderr)
        sys.exit(1)


if __name__ == "__main__":
    main()
