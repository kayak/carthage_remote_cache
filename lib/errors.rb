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

class VersionFileDoesNotExistError < AppError; end

class OutdatedFrameworkBuildError < AppError
  attr_reader :framework_name, :build_version, :cartfile_resolved_version

  def initialize(framework_name, build_version, cartfile_resolved_version)
    @framework_name = framework_name
    @build_version = build_version
    @cartfile_resolved_version = cartfile_resolved_version
  end

  def ==(o)
    self.class == o.class && state == o.state
  end

  def to_s
    "framework name: #{@framework_name}, build version: #{@build_version}, resolved version: #{@cartfile_resolved_version}"
  end

  protected

  def state
    [@framework_name, @build_version, @cartfile_resolved_version]
  end
end

class FrameworkValidationError < AppError
  def initialize(errors)
    @errors = errors
  end

  def to_s
    header = ["Framework", CARTHAGE_BUILD_DIR, CARTFILE_RESOLVED]
    rows = @errors.map { |e| [e.framework_name, e.build_version, e.cartfile_resolved_version] }
    table = Table.new(header, rows)
    <<~EOS
      Detected differences between existing frameworks in '#{CARTHAGE_BUILD_DIR}' and entries in '#{CARTFILE_RESOLVED}':

      #{table}

      To resolve the issue:
      - run `carthagerc download` to fetch missing frameworks from the server.
      - if the issue persists, run `carthage bootstrap` to build frameworks and `carthagerc upload` to populate the server.
    EOS
  end
end

class MissingFrameworkDirectoryError < AppError; end

class ServerVersionMismatchError < AppError; end
