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
        exists = response.code == 200
        puts "API: Framework exists: #{exists}" if @options[:verbose]
        exists
    end

    def upload_framework(zipfile_name, carthage_dependency, framework_name, platform)
        url = frameworkURL(carthage_dependency,framework_name, platform)
        puts "API: Uploading framework to #{url}" if @options[:verbose]
        RestClient.post(url, :framework_file => File.new(zipfile_name))
    end

    private def frameworkURL(carthage_dependency, framework_name, platform)
        # TODO uri = URI::HTTP.build(:host => "www.google.com", :query => { :q => "test" }.to_query)
        "#{@config.server}/framework/#{@config.xcodebuild_version}/#{@config.swift_version}/#{framework_name}/#{platform}/#{carthage_dependency.version}"
    end
end
