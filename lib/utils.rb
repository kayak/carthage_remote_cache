def sh(cmd)
    `#{cmd}`.strip
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
