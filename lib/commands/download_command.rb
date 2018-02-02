class DownloadCommand

    def initialize(options)
        @options = options
        @config = Configuration.new(options)
        @networking = Networking.new(@config, options)
        @api = API.new(@networking, options)
    end

    def run
        number_of_downloaded_archives = 0
        number_of_skipped_archives = 0
        for carthage_dependency in @config.carthage_dependencies
            puts '---' if @options[:verbose]

            local_version_file = if File.exist?(carthage_dependency.version_filepath)
                VersionFile.new(carthage_dependency.version_filepath)
            else
                nil
            end

            if !local_version_file.nil? && @api.version_file_matches_server?(carthage_dependency, local_version_file)
                puts "Version file #{local_version_file.path} matches server version, skipping download" if @options[:verbose]
                number_of_skipped_archives += local_version_file.number_of_frameworks
                next
            end

            version_file = @networking.download_version_file(carthage_dependency)
            raise "Version file #{carthage_dependency.version_filename} is not present on the server, please `upload` it first" if version_file.nil?

            version_file.frameworks_by_platform.each do |platform, framework_names|
                for framework_name in framework_names do
                    @api.download_and_unpack_archive(carthage_dependency, framework_name, platform)
                    number_of_downloaded_archives += 1
                end
            end
            version_file.move_to_build_dir
        end
        puts '---' if @options[:verbose]
        puts "Downloaded and extracted #{number_of_downloaded_archives} archives, skipped #{number_of_skipped_archives} archives."
    end

end
