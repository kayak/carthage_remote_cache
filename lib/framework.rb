# Example data:
# - "name" : "Sentry",
# - "linking" : "dynamic"
class Framework
  attr_reader :name

  def self.parse(json)
    Framework.new(json["name"], json["linking"])
  end

  def initialize(name, linking)
    @name = name
    @linking = linking
  end

  def make_archive(platform)
    FrameworkCarthageArchive.new(name, platform)
  end
end
