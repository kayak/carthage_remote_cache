def sh(cmd)
    output = `#{cmd}`
    bail("Command `#{cmd}` failed!") unless $?.success?
    output.strip
end

# Exits Ruby process, only to be called:
# 1. If sh / system calls fail
# 2. From top level `carthagerc` script
def bail(message, code = 1)
    $stderr.puts(message.strip + "\n")
    Process.exit(code)
end

# Quote command line arguments with double quotes.
# Useful for file paths with spaces.
def quote(input)
    if input.is_a? String
        if input.empty?
            ''
        else
            '"' + input + '"'
        end
    elsif input.is_a? Array
        input
            .map { |e| quote(e) }
            .select { |e| !e.empty? }
            .join(' ')
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
