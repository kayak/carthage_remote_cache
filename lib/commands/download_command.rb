class DownloadCommand

    def initialize(options)
        @options = options
        @config = Configuration.new(options)
        @api = ServerAPI.new(@config, options)
    end

    def run
        @number_of_downloaded_archives = 0
        for carthage_dependency in @config.carthage_dependencies
            for framework_name in carthage_dependency.produced_framework_names(@config)
                for platform in @config.platforms
                    download(carthage_dependency, framework_name, platform)
                end
            end
        end
        puts "Downloaded and extracted #{@number_of_downloaded_archives} archives."
    end

    private

    def download(carthage_dependency, framework_name, platform)
        puts '---' if @options[:verbose]
        archive = @api.download_framework(carthage_dependency, framework_name, platform)
        begin
            puts "Downloaded #{archive.archive_path}" if @options[:verbose]
            @number_of_downloaded_archives += 1
            archive.unpack_archive(@options)
        ensure
            archive.delete_archive
        end
    end

end
