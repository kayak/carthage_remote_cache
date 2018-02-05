require 'sinatra'
require 'fileutils'
require 'carthage_remote_cache'

get '/' do
    "Welcome to carthage_remote_cache"
end

versions_path = '/versions/:xcodebuild_version/:swift_version/:dependency_name/:version/:version_filename'
frameworks_path = '/frameworks/:xcodebuild_version/:swift_version/:dependency_name/:version/:framework_name/:platform'

get versions_path do
    dirname = params_to_framework_dir(params)
    filename = params[:version_filename]
    filepath = File.join(dirname, filename)

    if File.exist?(filepath)
        status(200)
        send_file(filepath)
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

    $LOG.info("Writing #{target_filename}")
    File.open(target_filename, 'wb') do |target_file|
        target_file.write(source_file.read)
    end

    status(200)
end

# Check whether framework archive is already cached.
head frameworks_path do
    dirname = params_to_framework_dir(params)
    archive = CarthageArchive.new(params[:framework_name], params[:platform].to_sym)
    filename = File.join(dirname, archive.archive_filename)

    if File.exist?(filename)
        status(200)
    else
        status(404)
    end
end

# Retrieve .zip framework archive.
get frameworks_path do
    dirname = params_to_framework_dir(params)
    archive = CarthageArchive.new(params[:framework_name], params[:platform].to_sym)
    filename = File.join(dirname, archive.archive_filename)

    if File.exist?(filename)
        status(200)
        send_file(filename)
    else
        status(404)
    end
end

# Upload framework archive. Overwrites already cached archive if exists.
post frameworks_path do
    filename = params[:framework_file][:filename]
    source_file = params[:framework_file][:tempfile]

    dirname = params_to_framework_dir(params)
    target_filename = File.join(dirname, filename)

    FileUtils.mkdir_p(dirname) unless File.directory?(dirname)
    File.delete(target_filename) if File.exist?(target_filename)

    $LOG.info("Writing: #{target_filename}")
    File.open(target_filename, 'wb') do |target_file|
        target_file.write(source_file.read)
    end

    status(200)
end

private

def params_to_framework_dir(params)
    File.join(SERVER_CACHE_DIR, params[:xcodebuild_version], params[:swift_version], params[:dependency_name], params[:version])
end
