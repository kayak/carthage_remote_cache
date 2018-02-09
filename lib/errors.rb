# Common type for all carthage_remote_cache Errors.
class AppError < StandardError; end

class CmdError < StandardError
  attr_reader :command

  def initialize(command)
    @command = command
  end
end

class MultipleErrorsError < AppError
  def initialize(errors)
    @errors = errors
  end

  def message
    @errors.map { |e| e.message }.join("\n")
  end
end

class OutdatedFrameworkBuildError < AppError; end

class MissingFrameworkDirectoryError < AppError; end
