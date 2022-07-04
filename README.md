# CarthageRemoteCache

[![Test Status](https://github.com/kayak/carthage_remote_cache/actions/workflows/ruby.yml/badge.svg)](https://github.com/kayak/carthage_remote_cache/actions/workflows/ruby.yml)
[![Gem Version](https://badge.fury.io/rb/carthage_remote_cache.svg)](https://badge.fury.io/rb/carthage_remote_cache)

Centralized cache to serve Carthage frameworks. Useful for distributed CI setup with several build machines. It's aware of your `xcodebuild` and `swift` versions and builds on top of Carthage's `.xyz.version` file mechanism.

## Installation

The gem is published at [rubygems.org](https://rubygems.org/gems/carthage_remote_cache), installation is as easy as:

    $ gem install carthage_remote_cache

_Note: Installing ri documentation for sinatra can be quite slow. Install with_ `--no-rdoc --no-ri` _if you don't want to wait._

## Quickstart

1. Run `carthagerc server` to start the cache on a remote server
2. `cd` to your project's root folder
3. Run `carthagerc init` to create `Cartrcfile` and point the server property to your  running server URL
4. Assuming your `Carthage` directory is already built, run `carthagerc upload` to populate remote cache
5. Push your `Cartrcfile` and from a different machine run `cartrcfile download` to fetch frameworks into `Carthage/Build/` folder
6. Build your app without having to wait for `carthage bootstrap`

## Usage

### Init

Before running any other commands, it's required to initialize `carthagerc` in your project directory by running:

    $ carthagerc init

Which produces a `Cartrcfile`. Configuration is done via plain `ruby` code, so it is as simple as:

    Configuration.setup do |c|
      c.server = "http://localhost:9292/"
    end

`Cartrcfile` is supposed to be version controlled (e.g. included in git repository), so that it lives along your code and all consumers of the repository have access to same configuration.

### Upload Workflow

Make sure that all your framework binaries have been built with `carthage`, otherwise there is nothing to upload.

    $ carthage bootstrap

Start the upload with:

    $ carthagerc upload

After couple of seconds you should be able to see confirmation in terminal:

    Uploaded 53 archives (97.2 MB), skipped 0.

#### Overwriting Existing Cache

Attempting to run `carthagerc upload` again will not upload any framework binaries, since all of them are already present on the cache server:

    Uploaded 0 archives (0.0 MB), skipped 53.

If your cache happens to be tainted by invalid framework binaries, you can overwrite existing cache with

    $ carthagerc upload --force

#### Upgrading Xcode or Swift

It is recommended to always perform the upload workflow after upgrading Xcode and Swift versions since `carthagerc` cached frameworks are not only bound to framework versions, but also to your build environment.

### Download Workflow

Once the cache server has been populated with framework binaries, it's time to fetch frameworks from a different machine. Make sure to pull in `Cartrcfile` from the repository before executing:

    $ carthagerc download

You should expect to see the following output on a machine with empty `Carthage` folder:

    Downloaded and extracted 53 archives (97.2 MB), skipped 0 archives.

Your project should be ready for building.

#### Overwrite Local Carthage Folder

In case you happen to change a file in `Carthage/Build` by accident, it's possible to force download all frameworks again with:

    $ carthagerc download --force

#### Download Only Some Platforms

The example above downloaded all frameworks for all platforms (iOS, macOS, tvOS, watchOS). If large dependencies or network speed are an issue, you can download only a subset of the platforms by using the `--platform` argument:

    $ carthagerc download --platform iOS,macOS,tvOS,watchOS

Please note, that invoking the `download` command multiple times with different platform arguments is not supported. The `.version` file will "forget" that `carthagerc` already downloaded the platform specified before the last download. If you need multiple platforms, specify them in a single `download` command once, delimited with a comma.

### Config

To get a quick overview on Xcode / Swift / Framework versions, execute

    $ carthagerc config

Which will print similar information:

    Xcodebuild: 9C40b
    ---
    Swift: 4.0.3
    ---
    Server: http://localhost:9292/
    ---
    Cartfile.resolved:
    github "kayak/attributions" "0.3"
    ---
    Local Build Frameworks:
    Attributions 0.3 [:iOS]

### Verify Framework Versions

When switching between development branches, it's very easy to lose track of whether existing framework binaries in `Carthage/Build` match version numbers from `Cartfile.resolved`. As a result, you will probably lose several minutes of your development time, because `Xcode` doesn't tell you about outdated or missing framework binaries.

Luckily, `carthage_remote_cache` provides following command:

    carthagerc verify

If existing frameworks match `Cartfile.resolved`, script exits with `0` and doesn't print anything.

In the event of framework version mismatch, you'll be able to observe following output:

    Detected differences between existing frameworks in 'Carthage/Build' and entries in 'Cartfile.resolved':

    +-----------------+----------------+-------------------+
    | Framework       | Carthage/Build | Cartfile.resolved |
    +-----------------+----------------+-------------------+
    | CocoaLumberjack |          3.2.1 |             3.4.1 |
    | PhoneNumberKit  |          1.3.0 |             2.1.0 |
    | HelloWorld      |              - |             3.0.0 |
    +-----------------+----------------+-------------------+

    To resolve the issue:
    - run `carthagerc download` to fetch missing frameworks from the server.
    - if the issue persists, run `carthage bootstrap` to build frameworks and `carthagerc upload` to populate the server.

#### Git Hook

Running `carthagerc verify` manually on every git checkout / merge / pull could be quite cumbersome. To automate this task, integrate following script [carthagerc-verify-githook](https://github.com/kayak/carthage_remote_cache/blob/master/integrations/carthagerc-verify-githook) into your repository's git hooks, e.g. `post-checkout`.

See `$ man githooks` for all available git hooks and their documentation.


### Cache Server

Start the server with

    $ carthagerc server

and browse to [localhost:9292](http://localhost:9292/) where you should be able to see the default _Welcome_ message.

Framework binaries will be stored in `~/.carthagerc_server` folder.

Server is bound to port 9292 by default. If you need to use different port, specify the port number via `-pPORT` or `--port=PORT` command line arguments, e.g.:

    $ carthage server -p9000
    $ carthage server --port=9000

Don't forget to change port number in your version controlled `Cartrcfile`.

#### Version Compatibility

Before each `carthagerc [upload|download]`, the script compares its version number against cache server. If the version doesn't match, `carthagerc` aborts with:

    Version mismatch:
      Cache server version: 0.0.7
      Client version:       0.0.6

    Please use the same version as cache server is using by running:
    $ gem install carthage_remote_cache -v 0.0.7

Please note, that this functionality only works with clients starting with version [0.0.6](https://github.com/kayak/carthage_remote_cache/releases/tag/0.0.6).

#### Directory Structure

Cache server stores version files and framework archives in following directory structure:

    .carthagerc_server/
      9C40b/                            # Xcode version
        4.0.3/                          # Swift version
          Framework1/
            1.0.0/                      # Framework1 version
              .Framework1.version       # Carthage .version file
              Framework1-iOS.zip        # Framework binary, dSYM and bcsymbolmap files
              Framework1-macOS.zip
              Framework1-tvOS.zip
              Framework1-watchOS.zip
            2.0.3/                      # Framework1 version
              .Framework1.version
              Framework1-iOS.zip
          Framework2/
            v3.2/                       # Framework2 version
              .Framework2.version
              Framework2-iOS.zip

It's safe to delete whole directories since no other metadata is stored.

#### Launch Agent

You can also run the cache server as a launch agent. Copy the template [com.kayak.carthagerc.server.plist](https://github.com/kayak/carthage_remote_cache/blob/master/integrations/com.kayak.carthagerc.server.plist) file to `~/Library/LaunchAgents`, change log
paths to include your username and run:

    $ launchctl load -w ~/Library/LaunchAgents/com.kayak.carthagerc.server.plist

If you want to stop the agent, run:

    $ launchctl unload ~/Library/LaunchAgents/com.kayak.carthagerc.server.plist

Check out official documentation on [Launch Agents](https://developer.apple.com/library/content/documentation/MacOSX/Conceptual/BPSystemStartup/Chapters/CreatingLaunchdJobs.html) for more info.

#### Docker

To build an image based on the latest released gem, run

    $ docker build -t carthagerc .

Afterwards you can run the image in a container using

    $ docker run -d --publish 9292:9292 --name carthagerc carthagerc:latest

The server will now be available on port 9292 on `localhost`. Note that the command above will cause any data added to `~/.carthagerc_server` to be written into the container layer. While this works, it's generally discouraged due to decreased performance and portability. To avoid this, you can use a volume.

    $ docker run -d --publish 9292:9292 --mount "source=carthagerc,target=/root/.carthagerc_server" --name carthagerc carthagerc:latest

We also recommend adding the `--log-opt` option to limit the size of logs, e.g. `--log-opt max-size=50m`.

To inspect the logs after running, use

    $ docker logs carthagerc

To stop the container, run

    $ docker container stop carthagerc

### Version

    $ carthagerc version

### Help

Documentation is also available when running `carthagerc` or `carthagerc --help`. Both commands print list of available commands with brief description.

    carthagerc COMMAND [OPTIONS]

    ...

    COMMANDS
        config
            print environment information and Cartrcfile configuration

        download [-f|--force] [-v|--verbose] [-mPLATFORM|--platform=PLATFORM]
            fetch missing frameworks into Carthage/Build

        init
            create initial Cartrcfile in current directory

        upload [-f|--force] [-v|--verbose]
            archive frameworks in Carthage/Build and upload them to the server

        server [-pPORT|--port=PORT]
            start cache server

        verify
            compare versions from Cartfile.resolved to existing frameworks in Carthage/Build

        version
            print current version number

    OPTIONS
        -f, --force                      Force upload/download of framework archives even if local and server .version files match
        -h, --help                       Show help
        -m, --platform=PLATFORM          Comma delimited list of platforms which should be downloaded from the server; e.g. `--platform iOS,macOS`; Supported values: iOS, macOS, tvOS, watchOS
        -n, --no-retry                   Don't retry download or upload on network failures
        -p, --port=PORT                  Server application port used when starting server, default port is 9292
        -v, --verbose                    Show extra runtime information

## Development

### Setup

After checking out the repo, run `dev/setup` to install dependencies. You can also run `dev/console` for an interactive prompt that will allow you to experiment.

### Development Server

To start development server, run `dev/start_server`, which utilizes `rerun` for automatic reloading of source code and resources.

### Tests

Execute unit tests with `rake test` or start monitoring directories for changes with `bundle exec guard`.

### Source Code Format

Before committing, make sure to auto-format source code wit `rake format`.

### Gem Lifecycle

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org/gems/carthage_remote_cache).

### Experiments With Example Folder

Repository is bundled with an example Carthage setup for your experiments. Open the [example](https://github.com/kayak/carthage_remote_cache/blob/master/example) folder, where you should be able to see following files, which are preconfigured to bring in a couple of frameworks:
- Cartfile
- Cartfile.resolved
- Cartrcfile

Make sure to build these dependencies with `carthage bootstrap` before attempting to upload them.

Try out a few commands:

    $ carthagerc config
    $ carthagerc upload
    $ carthagerc download

## License

The gem is available as open source under the terms of the [Apache 2.0 License](https://opensource.org/licenses/Apache-2.0).
