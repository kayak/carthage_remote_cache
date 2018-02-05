require 'rest-client'

class Networking

    def initialize(config)
        @config = config
    end

    # Version Files

    def download_version_file(carthage_dependency)
        url = version_file_url(carthage_dependency)
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

    def upload_version_file(carthage_dependency)
        url = version_file_url(carthage_dependency)
        $LOG.debug("Uploading #{carthage_dependency.version_filename}")
        RestClient.post(url, :version_file => File.new(carthage_dependency.version_filepath))
    end

    #  Archives

    def download_framework_archive(carthage_dependency, framework_name, platform)
        url = framework_url(carthage_dependency, framework_name, platform)
        $LOG.debug("Downloading framework from #{url}")
        archive = RestClient.get(url) do |response, request, result|
            if response.code == 200
                archive = CarthageArchive.new(framework_name, platform)
                File.write(archive.archive_path, response.to_s)
                archive
            else
                nil
            end
        end
        archive
    end

    def upload_framework_archive(zipfile_name, carthage_dependency, framework_name, platform)
        url = framework_url(carthage_dependency, framework_name, platform)
        $LOG.debug("Uploading framework to #{url}")
        RestClient.post(url, :framework_file => File.new(zipfile_name))
    end

    private

    def version_file_url(carthage_dependency)
        File.join(
            @config.server,
            'versions',
            sanitized(@config.xcodebuild_version),
            sanitized(@config.swift_version),
            sanitized(carthage_dependency.guessed_framework_basename),
            sanitized(carthage_dependency.version),
            sanitized(carthage_dependency.version_filename),
        )
    end

    def framework_url(carthage_dependency, framework_name, platform)
        # TODO uri = URI::HTTP.build(:host => "www.google.com", :query => URI.encode_www_form({ :q => "test" }))
        File.join(
            @config.server,
            'frameworks',
            sanitized(@config.xcodebuild_version),
            sanitized(@config.swift_version),
            sanitized(carthage_dependency.guessed_framework_basename),
            sanitized(carthage_dependency.version),
            sanitized(framework_name),
            platform_to_api_string(platform),
        )
    end

    # Mangle identifiers for URL paths.
    def sanitized(input)
        input.gsub(/\//, '_')
    end

end
