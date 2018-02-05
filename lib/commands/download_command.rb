require 'concurrent'

class DownloadCommand

    def initialize(options)
        @options = options
        @config = Configuration.new(options)
        @networking = Networking.new(@config, options)
        @api = API.new(@networking, options)
    end

    def run
        pool = Concurrent::FixedThreadPool.new(THREAD_POOL_SIZE)

        @number_of_downloaded_archives = 0
        @number_of_skipped_archives = 0
        exceptions = []

        for carthage_dependency in @config.carthage_dependencies
            pool.post(carthage_dependency) do |carthage_dependency|
                begin
                    download(carthage_dependency)
                rescue => e
                    exceptions << e
                end
            end
        end

        pool.shutdown
        pool.wait_for_termination

        puts '---' if @options[:verbose]
        puts "Downloaded and extracted #{@number_of_downloaded_archives} archives, skipped #{@number_of_skipped_archives} archives."
        bail(exceptions.map { |e| "#{e}" }.join("\n")) if exceptions.count > 0
    end

    private

    def download(carthage_dependency)
        local_version_file = if File.exist?(carthage_dependency.version_filepath)
            VersionFile.new(carthage_dependency.version_filepath)
        else
            nil
        end

        if !local_version_file.nil? && @api.version_file_matches_server?(carthage_dependency, local_version_file)
            puts "Version file #{local_version_file.path} matches server version, skipping download" if @options[:verbose]
            @number_of_skipped_archives += local_version_file.number_of_frameworks
            return
        end

        version_file = @networking.download_version_file(carthage_dependency)
        raise "Version file #{carthage_dependency.version_filename} is not present on the server, please run `carthagerc upload` first" if version_file.nil?

        version_file.frameworks_by_platform.each do |platform, framework_names|
            for framework_name in framework_names do
                archive = @api.download_and_unpack_archive(carthage_dependency, framework_name, platform)
                raise "Failed to download framework #{carthage_dependency} – #{framework_name} (#{platform}). Please `upload` the framework first." if archive.nil?
                @number_of_downloaded_archives += 1
            end
        end
        version_file.move_to_build_dir
    end

end
