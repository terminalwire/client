# Resolve the package root directory (two levels up from this file)
package_root = File.expand_path("../../", __FILE__)
vendor_path = File.join(package_root, "vendor")

# Add the Ruby standard library path
stdlib_path = File.join(vendor_path, "lib/ruby", RUBY_VERSION)
$LOAD_PATH.unshift(stdlib_path) unless $LOAD_PATH.include?(stdlib_path)

# Add all gem paths under vendor/gems to the load path
Dir.glob(File.join(ENV.fetch("GEM_HOME"), "gems/*/lib")).each do |gem_path|
  $LOAD_PATH.unshift(gem_path)
end

require "rubygems"

# Retrieve gem and binary name from arguments
gem_name = ARGV.shift || abort("Gem name is required")
binary_name = ARGV.shift || abort("Binary name is required")

# Load and execute the gem's binary
load Gem.activate_bin_path(gem_name, binary_name)
