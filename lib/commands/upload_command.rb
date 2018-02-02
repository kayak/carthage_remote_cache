class UploadCommand

    def initialize(options)
        @options = options
        @config = Configuration.new(options)
        @networking = Networking.new(@config, options)
        @api = API.new(@networking, options)
    end

    def run
        puts "All framework names: #{@config.all_framework_names}" if @options[:verbose]
        number_of_uploaded_archives = 0
        number_of_skipped_archives = 0
        for carthage_dependency in @config.carthage_dependencies
            puts '---' if @options[:verbose]

            version_file = VersionFile.new(carthage_dependency.version_filepath)

            if @api.version_file_matches_server?(carthage_dependency, version_file)
                puts "Version file #{version_file.path} matches server version, skipping upload" if @options[:verbose]
                number_of_skipped_archives += version_file.number_of_frameworks
                next
            end

            @networking.upload_version_file(carthage_dependency)

            version_file.frameworks_by_platform.each do |platform, framework_names|
                uploaded = false
                for framework_name in framework_names
                    @api.create_and_upload_archive(carthage_dependency, framework_name, platform)
                    number_of_uploaded_archives += 1
                end
            end
        end
        puts '---' if @options[:verbose]
        puts "Uploaded #{number_of_uploaded_archives} archives, skipped #{number_of_skipped_archives}."
    end

end
