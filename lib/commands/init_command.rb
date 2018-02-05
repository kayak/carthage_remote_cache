class InitCommand

    def initialize(options)
        @options = options
    end

    def run
        path = File.join(Dir.pwd, CARTRCFILE)
        if File.exist?(path)
            bail("File #{path} already exists, stopping")
        else
            File.write(path, file_contents)
        end
    end

    private

    def file_contents
        <<~EOS
            Configuration.setup do |c|
                c.server = "http://localhost:#{SERVER_DEFAULT_PORT}/"
            end
        EOS
    end

end
