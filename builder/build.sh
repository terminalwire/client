ROOT_PATH="$(dirname "$0")"

# Setup paths
BUILD_PATH="$PWD/build"

# We'll copy the package template into the build directory.
PACKAGE_PATH="$BUILD_PATH/package"

mkdir -p "$PACKAGE_PATH"

### Copy the package template into the build directory
cp -r "$ROOT_PATH/template/." "$PACKAGE_PATH/"

# Remove all the .gitkeep files
rm "$PACKAGE_PATH"/**/.gitkeep

# Where Ruby and gems are installed.
VENDOR_PATH="$PACKAGE_PATH/vendor"

# Ruby version to install and bundle with the package.
RUBY_VERSION="3.3.6"

### Build Ruby

# Check if ruby-install is present.
if ! command -v ruby-install &> /dev/null; then
  echo "Error: ruby-install is not installed." >&2
  exit 1
fi

# Install Ruby in the vendor directory.
ruby-install ruby "$RUBY_VERSION" --install-dir "$VENDOR_PATH"

### Install dependencies

# Now setup gem paths to point to the $VENDOR_PATH gems directory.
export GEM_HOME="$VENDOR_PATH/gems"
export GEM_PATH="$GEM_HOME"
export PATH="$VENDOR_PATH/bin:$PATH" # Add the Ruby binary to the path.
export BUNDLE_GEMFILE="$ROOT_PATH/Gemfile"

# Bundle the gems
bundle install

### Install the shim scripts
generate-gem-exec() {
  local gem_name="$1"
  local binary_name="$2"
  local shim_path="$PACKAGE_PATH/bin/$binary_name"

  mkdir -p "$(dirname "$shim_path")"

  # Create the shim script with the correct template
  cat <<EOF > "$shim_path"
#!/usr/bin/env bash

# Include the reusable functions
source "\$(cd "\$(dirname "\$0")" && pwd)/../lib/boot.sh"

# Call the gem_binary function with the appropriate gem and binary names
gem-exec "$gem_name" "$binary_name" "\$@"
EOF

  # Make the shim executable
  chmod +x "$shim_path"
  echo "Shim created at $shim_path"
}

# Example usage of shim function
generate-gem-exec "terminalwire" "terminalwire-exec"

# Define the tarball name
ARCHIVE_PATH="$BUILD_PATH/build.tar.gz"

# Create the tarball
echo "Packaging build directory into $ARCHIVE_PATH..."
tar -czf "$ARCHIVE_PATH" -C "$PACKAGE_PATH" .

# Calculate and display the file size in MB
FILE_SIZE_MB=$(du -m "$ARCHIVE_PATH" | cut -f1)

echo "Build packaged successfully at $ARCHIVE_PATH"
echo "Tarball size: ${FILE_SIZE_MB} MB"
