class MultipleErrorsError < StandardError

    def initialize(errors)
        @errors = errors
    end

    def message
        @errors.map { |e| e.message }.join("\n")
    end

end
