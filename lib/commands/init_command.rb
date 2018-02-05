class InitCommand

    def initialize(options)
        @options = options
    end

    def run
        path = File.join(Dir.pwd, CARTRCFILE)
        raise "File #{path} already exists, stopping" if File.exist?(path)

        File.write(path, file_contents)
    end

    private

    def file_contents
        <<~EOS
            server: http://localhost:#{SERVER_DEFAULT_PORT}/
        EOS
    end

end
