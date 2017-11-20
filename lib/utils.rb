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
