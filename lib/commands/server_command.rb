class ServerCommand

    def initialize(options)
        @options = options
    end

    def run
        require 'server/server_app'
        Rack::Handler::WEBrick.run(
            Sinatra::Application,
            :Port => @options[:server_port]
        )
    end

end
