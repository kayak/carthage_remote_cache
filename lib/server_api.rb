require 'rest-client'
require_relative 'configuration'

class ServerAPI

    def initialize(config, options)
        @config = config
        @options = options
    end

    def framework_exists(carthage_dependency, framework_name, platform)
        url = frameworkURL(carthage_dependency,framework_name, platform)
        puts "API: Checking if framework exists via #{url}" if @options[:verbose]
        response = RestClient.head(url) { |response, request, result| response }
        # TODO use response JSON instead of codes.
        exists = response.code == 200
        puts "API: Framework exists: #{exists}" if @options[:verbose]
        exists
    end

    def upload_framework(zipfile_name, carthage_dependency, framework_name, platform)
        url = frameworkURL(carthage_dependency,framework_name, platform)
        puts "API: Uploading framework to #{url}" if @options[:verbose]
        RestClient.post(url, :framework_file => File.new(zipfile_name))
    end

    private

    # TODO replace framework_name with repository
    def frameworkURL(carthage_dependency, framework_name, platform)
        # TODO uri = URI::HTTP.build(:host => "www.google.com", :query => URI.encode_www_form({ :q => "test" }))
        File.join(
            @config.server,
            'framework',
            sanitized(@config.xcodebuild_version),
            sanitized(@config.swift_version),
            sanitized(carthage_dependency.repository), # TODO doens't account for URL or file:// (git / binary)
            sanitized(framework_name),
            sanitized(platform),
            sanitized(carthage_dependency.version)
        )
    end

    # Mangle identifiers for URL paths.
    def sanitized(input)
        input.gsub(/\//, '_')
    end

end
