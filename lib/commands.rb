lib = File.expand_path("..", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

require 'commands/upload_command'
