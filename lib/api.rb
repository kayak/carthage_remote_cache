class API

    def initialize(networking, options)
        @networking = networking
        @options = options
    end

    def version_file_matches_server?(carthage_dependency, version_file)
        if @options[:force]
            false
        else
            server_version_file = @networking.download_version_file(carthage_dependency)
            result = version_file.same_content?(server_version_file)
            server_version_file.remove unless server_version_file.nil?
            result
        end
    end

    def create_and_upload_archive(carthage_dependency, framework_name, platform)
        archive = CarthageArchive.new(framework_name, platform)
        archive.create_archive
        begin
            @networking.upload_framework_archive(archive.archive_path, carthage_dependency, framework_name, platform)
        ensure
            archive.delete_archive
        end
    end

    def download_and_unpack_archive(carthage_dependency, framework_name, platform)
        archive = @networking.download_framework_archive(carthage_dependency, framework_name, platform)
        return nil if archive.nil?
        begin
            $LOG.debug("Downloaded #{archive.archive_path}")
            archive.unpack_archive
        ensure
            archive.delete_archive
        end
    end

end
