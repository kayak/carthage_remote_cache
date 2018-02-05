def sh(cmd)
    output = `#{cmd}`
    bail("Command `#{cmd}` failed!") unless $?.success?
    output.strip
end

# Exits Ruby process, only to be called:
# 1. If sh / system calls fail
# 2. From top level layer - `carthagerc` script or `*Command` classes
def bail(message, code = 1)
    $stderr.puts(message.strip + "\n")
    Process.exit(code)
end

def quote(input)
    if input.is_a? String
        '"' + input + '"'
    elsif input.is_a? Array
        input.map { |i| quote i }.join(" ")
    else
        raise "Unsupported type #{input}"
    end
end

def platform_to_api_string(platform)
    case platform
    when :iOS
        'iOS'
    when :macOS
        'macOS'
    when :tvOS
        'tvOS'
    when :watchOS
        'watchOS'
    else
        raise "Unrecognized platform #{platform.inspect}"
    end
end

def platform_to_carthage_dir_string(platform)
    case platform
    when :iOS
        'iOS'
    when :macOS
        'Mac'
    when :tvOS
        'tvOS'
    when :watchOS
        'watchOS'
    else
        raise "Unrecognized platform #{platform.inspect}"
    end
end
