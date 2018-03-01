require 'json'
require 'fileutils'

# .version file representation, see Carthage documentation on them:
# https://github.com/Carthage/Carthage/blob/master/Documentation/VersionFile.md
class VersionFile
  attr_reader :path, :version, :frameworks_by_platform

  def initialize(path)
    @path = path
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
      FileUtils.compare_file(@path, other_version_file.path)
    end
  end

  private

  def parse
    raise VersionFileDoesNotExistError.new, "File #{path} doesn't exist, has carthage been bootstrapped?" unless File.exist?(@path)

    file = File.read(@path)
    json = JSON.parse(file)

    @version = json['commitish']
    raise AppError.new, "Version is missing in #{@path}" if @version.nil? || @version.empty?

    @frameworks_by_platform = {
      :iOS => parse_platform_array(json['iOS']),
      :macOS => parse_platform_array(json['Mac']),
      :tvOS => parse_platform_array(json['tvOS']),
      :watchOS => parse_platform_array(json['watchOS']),
    }
  end

  def parse_platform_array(array)
    if array.kind_of?(Array)
      array.map { |entry| entry['name'] }
    else
      []
    end
  end
end
