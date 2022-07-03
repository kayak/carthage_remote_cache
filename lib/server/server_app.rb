require "json"
require "sinatra"
require "fileutils"
require "carthage_remote_cache"

get "/" do
  <<-eos
    <html>
      <p>Welcome to <strong>carthage_remote_cache</strong> (#{VERSION})</p>
      <p>To browse cache contents visit <a href="/browser/">/browser/</a></p>
    </html>
  eos
end

version_path = "/version"
versions_path = "/versions/:xcodebuild_version/:swift_version/:dependency_name/:version/:version_filename"
frameworks_path = "/frameworks/:xcodebuild_version/:swift_version/:dependency_name/:version/:framework_name/:platform"
browser_path = "/browser/*"

get version_path do
  status(200)
  VERSION
end

get versions_path do
  if params.key?(:platform)
    begin
      platforms = platform_to_symbols(params[:platform])
    rescue AppError => e
      status(400)
      return JSON.pretty_generate({ "error" => e.message })
    end
  else
    platforms = PLATFORMS
  end

  dirname = params_to_framework_dir(params)
  filename = params[:version_filename]
  filepath = File.join(dirname, filename)

  if File.exist?(filepath)
    status(200)
    version_file = VersionFile.new(filepath, platforms)
    JSON.pretty_generate(version_file.json)
  else
    status(404)
  end
end

post versions_path do
  dirname = params_to_framework_dir(params)
  filename = params[:version_filename]

  source_file = params[:version_file][:tempfile]
  target_filename = File.join(dirname, filename)

  FileUtils.mkdir_p(dirname) unless File.directory?(dirname)
  File.delete(target_filename) if File.exist?(target_filename)

  $LOG.info("Writing: #{target_filename}")
  File.open(target_filename, "wb") do |target_file|
    target_file.write(source_file.read)
  end

  status(200)
end

# Retrieve .zip framework archive.
get frameworks_path do
  dirname = params_to_framework_dir(params)
  archive = CarthageArchive.new(params[:framework_name], params[:platform].to_sym)
  filename = File.join(dirname, archive.archive_filename)

  if File.exist?(filename)
    headers[ARCHIVE_CHECKSUM_HEADER_SINATRA_OUT] = crc32(filename)
    status(200)
    send_file(filename)
  else
    status(404)
    "Missing framework archive at '#{filename}'"
  end
end

# Upload framework archive. Overwrites already cached archive if exists.
post frameworks_path do
  expected_checksum = request.env[ARCHIVE_CHECKSUM_HEADER_SINATRA_IN]
  filename = params[:framework_file][:filename]
  source_file = params[:framework_file][:tempfile]

  dirname = params_to_framework_dir(params)
  target_filename = File.join(dirname, filename)

  FileUtils.mkdir_p(dirname) unless File.directory?(dirname)
  File.delete(target_filename) if File.exist?(target_filename)

  $LOG.info("Writing: #{target_filename}")
  File.open(target_filename, "wb") do |target_file|
    target_file.write(source_file.read)
  end

  checksum = crc32(target_filename)
  if checksum == expected_checksum
    status(200)
  else
    File.delete(target_filename)
    message = "Checksums for '#{target_filename}' don't match. Expected '#{expected_checksum}', got '#{checksum}'"
    $LOG.error(message)
    status(500)
    message
  end
end

# Full blown file browser.
get browser_path do
  url_path = "/" + params["splat"][0]
  path = File.join(SERVER_CACHE_DIR, url_path)

  if File.file?(path)
    status(200)
    send_file(path)
  else
    html = "<html>"

    # Current directory
    html += "<h2>#{url_path}</h2>"

    # ".." link
    if url_path != "/"
      parent = File.dirname(url_path)
      parent += "/" if parent != "/"
      html += "<p><a href=\"/browser#{parent}\">..</a></p>"
    end

    # Child links
    for name in Dir.children(path).select { |name| name != ".DS_Store" }.sort
      child_path = File.join(path, name)
      html += "<p>"
      if File.file?(child_path)
        html += "<a href=\"#{name}\">#{name}</a> #{format_file_size(File.size(child_path))}"
      else
        html += "<a href=\"#{name}/\">#{name}/</a>"
      end
      html += " <span style=\"color:#777\">#{File.ctime(child_path).to_s}</span>"
      html += "</p>"
    end

    html
  end
end

private

def params_to_framework_dir(params)
  File.join(SERVER_CACHE_DIR, params[:xcodebuild_version], params[:swift_version], params[:dependency_name], params[:version])
end
