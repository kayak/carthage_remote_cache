# Exits Ruby process, only to be called from top level `carthagerc` script
def bail(message, code = 1)
  $stderr.puts(message.strip + "\n")
  Process.exit(code)
end

def crc32(filename)
  checksum = Digest::CRC32.file(filename).hexdigest
  $LOG.debug("CRC32 checksum for '#{filename}': #{checksum}")
  checksum
end

# Quote command line arguments with double quotes.
# Useful for file paths with spaces.
def quote(input)
  if input.is_a? String
    if input.empty?
      ""
    else
      '"' + input + '"'
    end
  elsif input.is_a? Array
    input
      .map { |e| quote(e) }
      .select { |e| !e.empty? }
      .join(" ")
  else
    raise AppError.new, "Unsupported type #{input}"
  end
end

def platform_to_api_string(platform)
  case platform
  when :iOS
    "iOS"
  when :macOS
    "macOS"
  when :tvOS
    "tvOS"
  when :watchOS
    "watchOS"
  else
    raise AppError.new, "Unrecognized platform #{platform.inspect}"
  end
end

def platform_to_carthage_dir_string(platform)
  case platform
  when :iOS
    "iOS"
  when :macOS
    "Mac"
  when :tvOS
    "tvOS"
  when :watchOS
    "watchOS"
  else
    raise AppError.new, "Unrecognized platform #{platform.inspect}"
  end
end

def platform_to_symbols(string)
  platforms = string.split(",").map(&:to_sym)
  for platform in platforms
    if !PLATFORMS.include?(platform)
      raise PlatformMismatchError.new(platform)
    end
  end
  platforms
end

# @return string in "x.y MB" format
def format_file_size(bytes)
  megabytes = bytes / 1000.0 / 1000.0
  "#{megabytes.round(1)} MB"
end
