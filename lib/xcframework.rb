# Example data:
# - "name" : "GoogleSignIn",
# - "container" : "GoogleSignIn.xcframework",
# - "identifiers" : ["ios-arm64_i386_x86_64-simulator", "ios-arm64_armv7"]
class XCFramework
  attr_reader :name, :container, :identifiers

  def self.parse(json)
    XCFramework.new(json["name"], json["container"], [json["identifier"]])
  end

  def initialize(name, container, identifiers)
    @name = name
    @container = container
    @identifiers = identifiers
  end

  def ==(other)
    @name == other.name && @container == other.container && @identifiers == other.identifiers
  end

  def make_archive(platform)
    XCFrameworkCarthageArchive.new(name, platform)
  end

  def new_xcframework_by_adding_identifiers(identifiers_to_add)
    XCFramework.new(name, container, identifiers + identifiers_to_add)
  end
end
