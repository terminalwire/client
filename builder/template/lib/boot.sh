#!/usr/bin/env bash

# Resolve the directory of this script
BOOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
RUBY_PATH="$BOOT_DIR/../vendor/bin/ruby"
BOOT_FILE="$BOOT_DIR/boot.rb"

export GEM_HOME="$BOOT_DIR/../vendor/gems"
export GEM_PATH="$GEM_HOME"

# Function to boot a gem binary
gem-exec() {
  local gem_name="$1"
  local binary_name="$2"
  shift 2 # Remove gem and binary name arguments

  # Call the Ruby binary with the boot file and pass the remaining arguments
  "$RUBY_PATH" "$BOOT_FILE" "$gem_name" "$binary_name" "$@"
}
