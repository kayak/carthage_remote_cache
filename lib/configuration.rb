require "uri"

class Configuration
  class UserConfig
    attr_accessor :server
  end

  @@user_config = UserConfig.new

  def self.setup
    yield(@@user_config)
  end

  attr_reader :carthage_resolved_dependencies, :server_uri

  def self.new_with_defaults
    Configuration.new(ShellWrapper.new)
  end

  def initialize(shell)
    @shell = shell
    initialize_cartfile_resolved
    initialize_cartrcfile
  end

  def all_framework_names
    version_files.flat_map { |vf| vf.framework_names }.uniq.sort
  end

  # Ensure, that these lazy properties are loaded before kicking off async code.
  def ensure_shell_commands
    xcodebuild_version
    swift_version
  end

  def xcodebuild_version
    if @xcodebuild_version.nil?
      xcodebuild_raw_version = @shell.xcodebuild_version
      @xcodebuild_version = xcodebuild_raw_version[/Build version (.*)$/, 1]
      raise AppError.new, "Could not parse build version from '#{xcodebuild_raw_version}'" if @xcodebuild_version.nil?
    end
    @xcodebuild_version
  end

  def swift_version
    if @swift_version.nil?
      swift_raw_version = @shell.swift_version
      @swift_version = swift_raw_version[/Apple Swift version (.*) \(/, 1]
      raise AppError.new, "Could not parse swift version from '#{raw_swift_version}'" if @swift_version.nil?
    end
    @swift_version
  end

  def to_s
    <<~EOS
      Xcodebuild: #{xcodebuild_version}
      ---
      Swift: #{swift_version}
      ---
      Server: #{@server_uri.to_s}
      ---
      Cartfile.resolved:
      #{@carthage_resolved_dependencies.join("\n")}
      ---
      Local Build Frameworks:
      #{framework_names_with_platforms.join("\n")}
    EOS
  end

  private

  def initialize_cartfile_resolved
    raise AppError.new, "Misssing #{CARTFILE_RESOLVED}" unless File.exist?(CARTFILE_RESOLVED)
    @carthage_resolved_dependencies = File.readlines(CARTFILE_RESOLVED)
      .map { |line| CarthageDependency.parse_cartfile_resolved_line(line) }
      .compact
  end

  def initialize_cartrcfile
    raise AppError.new, "Configuration file #{CARTRCFILE} was not found, consider creating one by running `carthagerc init`" unless File.exist?(CARTRCFILE)

    # Populate class variable @@user_config.
    load File.join(Dir.pwd, CARTRCFILE)

    raise AppError.new, "Missing 'server' configuration in #{CARTRCFILE}" if @@user_config.server.nil? || @@user_config.server.empty?
    @server_uri = URI.parse(@@user_config.server)
  end

  def framework_names_with_platforms
    lines = version_files.flat_map do |vf|
      vf.platforms_by_framework.flat_map do |framework_name, platforms|
        "#{framework_name} #{vf.version} #{platforms}"
      end
    end
    lines.sort
  end

  def version_files
    @carthage_resolved_dependencies.map { |d| d.new_version_file }
  end
end
