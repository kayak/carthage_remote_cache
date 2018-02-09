require 'rest-client'
require 'uri'

class Networking
  def initialize(config)
    @config = config
  end

  # Version Files

  # @return VersionFile or nil
  def download_version_file(carthage_dependency)
    url = new_version_file_url(carthage_dependency)
    $LOG.debug("Downloading version file from #{url}")
    version_file = RestClient.get(url) do |response, request, result|
      if response.code == 200
        File.write(carthage_dependency.version_filename, response.to_s)
        VersionFile.new(carthage_dependency.version_filename)
      else
        nil
      end
    end
    version_file
  end

  # @raise AppError on upload failure
  def upload_version_file(carthage_dependency)
    url = new_version_file_url(carthage_dependency)
    $LOG.debug("Uploading #{carthage_dependency.version_filename}")
    RestClient.post(url, :version_file => File.new(carthage_dependency.version_filepath)) do |response, request, result|
      unless response.code == 200
        raise AppError.new, "Version file upload #{carthage_dependency.version_filename} failed, response:\n  #{response[0..300]}"
      end
    end
  end

  #  Archives

  # @return Hash with CarthageArchive and checksum or nil
  def download_framework_archive(carthage_dependency, framework_name, platform)
    url = new_framework_url(carthage_dependency, framework_name, platform)
    $LOG.debug("Downloading framework from #{url}")
    archive = RestClient.get(url) do |response, request, result|
      if response.code == 200
        archive = CarthageArchive.new(framework_name, platform)
        File.write(archive.archive_path, response.to_s)
        {:archive => archive, :checksum => response.headers[ARCHIVE_CHECKSUM_HEADER_REST_CLIENT]}
      else
        nil
      end
    end
    archive
  end

  # @raise AppError when upload fails
  def upload_framework_archive(zipfile_name, carthage_dependency, framework_name, platform, checksum)
    url = new_framework_url(carthage_dependency, framework_name, platform)
    params = {:framework_file => File.new(zipfile_name)}
    headers = {ARCHIVE_CHECKSUM_HEADER_REST_CLIENT => checksum}
    $LOG.debug("Uploading framework to #{url}, headers: #{headers}")
    RestClient.post(url, params, headers) do |response, request, result|
      unless response.code == 200
        raise AppError.new, "Framework upload #{zipfile_name} failed, response:\n  #{response[0..300]}"
      end
    end
  end

  private

  def new_version_file_url(carthage_dependency)
    new_server_url([
      'versions',
      @config.xcodebuild_version,
      @config.swift_version,
      carthage_dependency.guessed_framework_basename,
      carthage_dependency.version,
      carthage_dependency.version_filename,
    ])
  end

  def new_framework_url(carthage_dependency, framework_name, platform)
    new_server_url([
      'frameworks',
      @config.xcodebuild_version,
      @config.swift_version,
      carthage_dependency.guessed_framework_basename,
      carthage_dependency.version,
      framework_name,
      platform_to_api_string(platform),
    ])
  end

  def new_server_url(path_slices)
    sanitized_path_slices = path_slices.map { |p| sanitized(p) }
    uri = URI::HTTP.build(
      :scheme => @config.server_uri.scheme,
      :host => @config.server_uri.host,
      :port => @config.server_uri.port,
      :path => '/' + sanitized_path_slices.join('/'),
    )
    uri.to_s
  end

  # Mangle identifiers for URL paths.
  def sanitized(input)
    input.gsub(/\//, '_')
  end
end
