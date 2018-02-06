# Common type for all carthage_remote_cache Errors.
class AppError < StandardError; end

class MultipleErrorsError < AppError

    def initialize(errors)
        @errors = errors
    end

    def message
        @errors.map { |e| e.message }.join("\n")
    end

end

class OutdatedFrameworkBuildError < AppError; end
