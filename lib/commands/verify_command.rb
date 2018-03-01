class VerifyCommand
  def self.new_with_defaults(options)
    shell = ShellWrapper.new
    config = Configuration.new(shell)
    networking = Networking.new(config)
    api = API.new(shell, config, networking, options)

    VerifyCommand.new(api: api)
  end

  def initialize(args)
    @api = args[:api]
  end

  def run
    @api.verify_build_dir_matches_cartfile_resolved
  end
end
