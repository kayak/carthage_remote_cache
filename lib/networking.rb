require "rest-client"
require "uri"

class Networking
  def initialize(config, is_retry_enabled)
    @config = config
    @is_retry_enabled = is_retry_enabled
  end

  # Version

  def get_server_version
    url = new_version_url
    $LOG.debug("Fetching server version from #{url}")
    server_version = perform_network_request do
      RestClient.get(url) do |response, request, result|
        if response.code == 200
          response.strip
        else
          raise AppError.new, "Failed to read server version from #{url}, response:\n  #{response[0...300]}"
        end
      end
    end
    server_version
  end

  # Version Files

  # @return VersionFile or nil
  def download_version_file(carthage_dependency, platforms)
    url = new_version_file_url(carthage_dependency)
    params = {}
    unless platforms.nil?
      params[:platform] = platforms.map(&:to_s).join(",")
    end

    version_file = perform_network_request do
      $LOG.debug("Downloading version file from #{url}, params: #{params}")
      RestClient.get(url, { params: params }) do |response, request, result|
        if response.code == 200
          File.write(carthage_dependency.version_filename, response.to_s)
          VersionFile.new(carthage_dependency.version_filename)
        else
          nil
        end
      end
    end
    version_file
  end

  # @raise AppError on upload failure
  def upload_version_file(carthage_dependency)
    url = new_version_file_url(carthage_dependency)
    perform_network_request do
      $LOG.debug("Uploading #{carthage_dependency.version_filename}")
      RestClient.post(url, :version_file => File.new(carthage_dependency.version_filepath)) do |response, request, result|
        unless response.code == 200
          raise AppError.new, "Version file upload #{carthage_dependency.version_filename} failed, response:\n  #{response[0..300]}"
        end
      end
    end
  end

  #  Archives

  # @return Hash with CarthageArchive and checksum or nil
  def download_framework_archive(carthage_dependency, framework, platform)
    url = new_framework_url(carthage_dependency, framework.name, platform)
    archive = perform_network_request do
      $LOG.debug("Downloading framework from #{url}")
      RestClient.get(url) do |response, request, result|
        if response.code == 200
          archive = framework.make_archive(platform)
          File.write(archive.archive_path, response.to_s)
          { :archive => archive, :checksum => response.headers[ARCHIVE_CHECKSUM_HEADER_REST_CLIENT] }
        else
          nil
        end
      end
    end
    archive
  end

  # @raise AppError when upload fails
  def upload_framework_archive(zipfile_name, carthage_dependency, framework_name, platform, checksum)
    url = new_framework_url(carthage_dependency, framework_name, platform)
    params = { :framework_file => File.new(zipfile_name) }
    headers = { ARCHIVE_CHECKSUM_HEADER_REST_CLIENT => checksum }
    perform_network_request do
      $LOG.debug("Uploading framework to #{url}, headers: #{headers}")
      RestClient.post(url, params, headers) do |response, request, result|
        unless response.code == 200
          raise AppError.new, "Framework upload #{zipfile_name} failed, response:\n  #{response[0..300]}"
        end
      end
    end
  end

  private

  def new_version_url
    new_server_url(["version"])
  end

  def new_version_file_url(carthage_dependency)
    new_server_url([
      "versions",
      @config.xcodebuild_version,
      @config.swift_version,
      carthage_dependency.guessed_framework_basename,
      carthage_dependency.version,
      carthage_dependency.version_filename,
    ])
  end

  def new_framework_url(carthage_dependency, framework_name, platform)
    new_server_url([
      "frameworks",
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
      :path => "/" + sanitized_path_slices.join("/"),
    )
    uri.to_s
  end

  # Mangle identifiers for URL paths.
  def sanitized(input)
    input.gsub(/\//, "_")
  end

  def perform_network_request
    if @is_retry_enabled
      retries_remaining = 3
      sleep_time_seconds = 5
      begin
        result = yield
      rescue Timeout::Error, Errno::EINVAL, Errno::ECONNRESET, EOFError,
             Net::HTTPBadResponse, Net::HTTPHeaderSyntaxError, Net::ProtocolError, SocketError => e
        if retries_remaining > 0
          $LOG.warn("Network request failed - remaining retries: #{retries_remaining}, sleeping for: #{sleep_time_seconds}s, error: #{e.message}")
          sleep(sleep_time_seconds)
          retries_remaining -= 1
          sleep_time_seconds *= 3
          retry
        else
          raise e
        end
      end
      result
    else
      yield
    end
  end
end
