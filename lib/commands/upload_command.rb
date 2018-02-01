class UploadCommand

    def initialize(options)
        @options = options
        @config = Configuration.new(options)
        @api = ServerAPI.new(@config, options)
    end

    def run
        puts "All framework names: #{@config.all_framework_names}" if @options[:verbose]
        @number_of_uploaded_archives = 0
        @number_of_skipped_archives = 0
        for carthage_dependency in @config.carthage_dependencies
            for framework_name in carthage_dependency.produced_framework_names(@config)
                for platform in @config.platforms
                    upload(carthage_dependency, framework_name, platform)
                end
            end
        end
        puts "Uploaded #{@number_of_uploaded_archives} archives, skipped #{@number_of_skipped_archives}."
    end

    private

    def upload(carthage_dependency, framework_name, platform)
        puts '---' if @options[:verbose]

        if @api.framework_exists(carthage_dependency, framework_name, platform)
            @number_of_skipped_archives += 1
            return
        end

        archive = CarthageArchive.new(framework_name, platform)
        archive_created = archive.create_archive(@options)
        unless archive_created
            @number_of_skipped_archives += 1
            return
        end

        begin
            @api.upload_framework(archive.archive_path, carthage_dependency, framework_name, platform)
            @number_of_uploaded_archives += 1
        ensure
            archive.delete_archive
        end
    end

end
