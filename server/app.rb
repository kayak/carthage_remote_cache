require 'sinatra'
require 'fileutils'
require_relative '../lib/carthage_archive'

get '/' do
    "Root, will list all frameworks and versions"
end

# Check whether framework archive is already cached.
head '/framework/:xcodebuild_version/:swift_version/:repository/:framework_name/:platform/:version' do
    dirname = params_to_framework_dir(params)
    archive = CarthageArchive.new(params[:framework_name], params[:platform])
    filename = File.join(dirname, archive.archive_filename)

    if File.exists?(filename)
        status 200
    else
        status 404
    end
end

# Upload framework archive. Overwrites already cached archive if exists.
post '/framework/:xcodebuild_version/:swift_version/:repository/:framework_name/:platform/:version' do
    filename = params[:framework_file][:filename]
    source_file = params[:framework_file][:tempfile]

    dirname = params_to_framework_dir(params)
    target_filename = File.join(dirname, filename)

    FileUtils.mkdir_p(dirname) unless File.directory?(dirname)
    File.delete(target_filename) if File.exists?(target_filename)

    puts "Writing: #{target_filename}"
    File.open(target_filename, 'wb') do |target_file|
        target_file.write(source_file.read)
    end

    status 200
end

private

def params_to_framework_dir(params)
    cache_dir = '/tmp/carthage-remote-cache' # TODO config
    File.join(cache_dir, params[:xcodebuild_version], params[:swift_version], params[:repository], params[:framework_name], params[:version])
end
