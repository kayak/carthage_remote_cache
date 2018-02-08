lib = File.expand_path("..", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

require 'api'
require 'carthage_archive'
require 'carthage_dependency'
require 'constants'
require 'configuration'
require 'errors'
require 'log'
require 'networking'
require 'shell_wrapper'
require 'utils'
require 'version'
require 'version_file'
