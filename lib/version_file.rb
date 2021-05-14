require "json"
require "fileutils"

# .version file representation, see Carthage documentation on them:
# https://github.com/Carthage/Carthage/blob/master/Documentation/VersionFile.md
class VersionFile
  attr_reader :path, :platforms, :json, :version, :frameworks_by_platform

  def initialize(path, platforms = PLATFORMS)
    @path = path
    @platforms = platforms
    parse
  end

  # Returns a Hash, e.g.
  # ```
  # {
  #   "CocoaLumberjack" => [:iOS, :watchOS],
  #   "Lottie" => [:iOS],
  # }
  # ```
  def platforms_by_framework
    result = Hash.new { |h, k| h[k] = [] }
    for framework_name in framework_names
      @frameworks_by_platform.each do |platform, framework_names_in_platform|
        if framework_names_in_platform.include?(framework_name)
          result[framework_name] << platform
        end
      end
    end
    result
  end

  # Unique array of framework names.
  def framework_names
    @frameworks_by_platform.values.flatten.uniq.sort
  end

  # Total number of frameworks accross all platforms.
  def number_of_frameworks
    @frameworks_by_platform.values.flatten.count
  end

  def move_to_build_dir
    basename = File.basename(@path)
    target_path = File.join(CARTHAGE_BUILD_DIR, basename)
    FileUtils.mv(@path, target_path)
    @path = target_path
  end

  def remove
    FileUtils.rm(@path)
  end

  def same_content?(other_version_file)
    if other_version_file.nil?
      false
    else
      @json == other_version_file.json
    end
  end

  private

  def parse
    raise VersionFileDoesNotExistError.new, "File #{path} doesn't exist, has carthage been bootstrapped?" unless File.exist?(@path)

    @json = read_json

    @version = @json["commitish"]
    raise AppError.new, "Version is missing in #{@path}:\n\n#{@json}" if @version.nil? || @version.empty?

    @frameworks_by_platform = PLATFORMS.to_h { |platform| [platform, parse_platform(platform)] }
  end

  # Reads json from `@path` and cleans up entries, tha are not defined in `@platforms`.
  def read_json
    file = File.read(@path)
    json = JSON.parse(file)
    stripped_json = strip_platforms(json)
    stripped_json
  end

  def strip_platforms(json)
    for platform in PLATFORMS
      if !@platforms.include?(platform)
        json[platform_to_carthage_dir_string(platform)] = []
      end
    end
    json
  end

  def parse_platform(platform)
    carthage_platform_name = platform_to_carthage_dir_string(platform)
    array = @json[carthage_platform_name]
    if array.kind_of?(Array)
      array.map { |entry| entry["name"] }
    else
      []
    end
  end
end
