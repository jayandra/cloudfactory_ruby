module CloudFactory
  module ClientRequestResponse

    extend ActiveSupport::Concern

    module ClassMethods
      def get(*args); handle_response super end

      def post(*args); handle_response super end

      def handle_response(response)
        debugger
        case response.code
        when 401; raise Unauthorized.new
        when 403; raise RateLimitExceeded.new
        when 404; raise NotFound.new
        when 400...500; raise ClientError.new(response.parsed_response.to_s)
        when 500...600; raise ServerError.new(response.code)
        else; response
        end
        if response.is_a?(Array)
          response.map{|item| Hashie::Mash.new(item)}
        else
          Hashie::Mash.new(response)
        end
      end
    end
  end
end