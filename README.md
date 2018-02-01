# CarthageRemoteCache

## Installation

The gem is published at [rubygems.org](https://rubygems.org/gems/carthage_remote_cache), installation is as easy as:

    $ gem install carthage_remote_cache

## Usage

### Server

Start the server with

    $ carthagerc server

and browse to [localhost:9292](http://localhost:9292/) whereyou should be able to see the default _Welcome_ message.

Server is bound to port 9292 by default. If you need to use different port, specify the port number via `-pPORT` or `--port=PORT` command line arguments, e.g.:

    $ carthage server -p9000
    $ carthage server --port=9000

### Carthage Preparation

### Artifact Upload
    $ carthagerc upload

### Artifact Download
    $ carthagerc download

### Help

Documentation is also available when running `carthagerc` or `carthagerc --help`. Both commands print list of available commands with brief description.

## Development

After checking out the repo, run `dev/setup` to install dependencies. You can also run `dev/console` for an interactive prompt that will allow you to experiment.

To start development server, run `dev/start_server`, which utilizes `rerun` for automatic reloading of source code and resources.Â

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `carthage_remote_cache.gemspec`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org/gems/carthage_remote_cache).

### Example Folder

Repository is bundled with an example Carthage setup – open the `example` folder, where  you should be able to see following files, which are preconfigured to bring in a couple of frameworks:
- Cartfile
- Cartfile.resolved
- Cartrcfile

#### Upload

First of all, build Carthage dependencies:

    $ carthage update --no-build && carthage bootstrap

After the `Carthage/Build` folder gets populated, execute:

    $ carthagerc upload

You should be able to observe the `/tmp/carthage_remote_cache` folder filling.

#### Download

    $ carthagerc download

## License

The gem is available as open source under the terms of the [Apache 2.0 License](https://opensource.org/licenses/Apache-2.0).
