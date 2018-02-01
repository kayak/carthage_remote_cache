lib = File.expand_path("..", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

require 'carthage_archive'
require 'carthage_dependency'
require 'configuration'
require 'server_api'
require 'utils'
