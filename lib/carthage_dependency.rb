# Representation of a Cartfile.resolved entry.
# @see https://github.com/Carthage/Carthage/blob/master/Documentation/Artifacts.md#origin
class CarthageDependency
  class << self
    # Parses Cartfile.resolved dependency entry, e.g.
    #   github "CocoaLumberjack/CocoaLumberjack" "3.2.1"
    def parse_cartfile_resolved_line(line)
      line.strip!
      matches = line.match(/^(\w+)\s+\"([^\"]+)\"(\s+\"([^\"]+)\")$/)
      return nil if matches.nil?
      if matches.length == 5
        CarthageDependency.new(origin: matches[1].to_sym, source: matches[2], version: matches[4])
      else
        nil
      end
    end
  end

  attr_reader :origin, :source, :version

  def initialize(args)
    raise AppError.new, "Expected Symbol for origin '#{args[:origin]}'" unless args[:origin].kind_of? Symbol
    raise AppError.new, "Unrecognized origin '#{args[:oriign]}'" unless [:github, :git, :binary].include?(args[:origin])

    @origin = args[:origin]
    @source = args[:source]
    @version = args[:version]
  end

  def new_version_file
    VersionFile.new(version_filepath)
  end

  # Since one Cartfile.resolved entry may produce multiple differently named frameworks,
  # this is an entry point to identifying a framework name.
  def guessed_framework_basename
    case @origin
    when :github
      @source.split("/").last
    when :git
      filename = @source.split("/").last
      filename.chomp(".git")
    when :binary
      filename = @source.split("/").last
      filename.chomp(".json")
    else
      raise AppError.new, "Unrecognized origin '#{@origin}'"
    end
  end

  def version_filename
    ".#{guessed_framework_basename}.version"
  end

  def version_filepath
    File.join(CARTHAGE_BUILD_DIR, version_filename)
  end

  def verify_version_in_version_file(version_file)
    if @version != version_file.version
      raise OutdatedFrameworkBuildError.new(guessed_framework_basename, version_file.version, @version)
    end
  end

  def to_s
    "#{@origin.to_s} \"#{@source}\" \"#{@version}\""
  end
end
