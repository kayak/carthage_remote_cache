require 'concurrent'

class UploadCommand

    def initialize(options)
        @options = options
        @config = Configuration.new(options)
        @networking = Networking.new(@config, options)
        @api = API.new(@networking, options)
    end

    def run
        pool = Concurrent::FixedThreadPool.new(THREAD_POOL_SIZE)

        puts "All framework names: #{@config.all_framework_names}" if @options[:verbose]

        @number_of_uploaded_archives = 0
        @number_of_skipped_archives = 0
        exceptions = []

        for carthage_dependency in @config.carthage_dependencies
            pool.post(carthage_dependency) do |carthage_dependency|
                begin
                    upload(carthage_dependency)
                rescue => e
                    exceptions << e
                end
            end
        end

        pool.shutdown
        pool.wait_for_termination

        puts '---' if @options[:verbose]
        puts "Uploaded #{@number_of_uploaded_archives} archives, skipped #{@number_of_skipped_archives}."
        bail(exceptions.map { |e| "#{e}" }.join("\n")) if exceptions.count > 0
    end

    private

    def upload(carthage_dependency)
        version_file = VersionFile.new(carthage_dependency.version_filepath)

        if @api.version_file_matches_server?(carthage_dependency, version_file)
            puts "Version file #{version_file.path} matches server version, skipping upload" if @options[:verbose]
            @number_of_skipped_archives += version_file.number_of_frameworks
            return
        end

        @networking.upload_version_file(carthage_dependency)

        version_file.frameworks_by_platform.each do |platform, framework_names|
            for framework_name in framework_names
                @api.create_and_upload_archive(carthage_dependency, framework_name, platform)
                @number_of_uploaded_archives += 1
            end
        end
    end

end
