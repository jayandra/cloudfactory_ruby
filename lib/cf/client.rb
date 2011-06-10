module CF
  module Client

    extend ActiveSupport::Concern

    module ClassMethods
      def default_params
        {:api_key => CF.api_key}
      end

      def get(*args)
        handle_response RestClient.get("#{CF.api_url}#{CF.api_version}#{args.first}", :params => default_params, :accept => 'json')
      end

      def post(*args)
        handle_response  RestClient.post("#{CF.api_url}#{CF.api_version}#{args.first}", args.last.merge!(default_params), :accept => 'json')
      end

      def put(*args)
        handle_response  RestClient.put("#{CF.api_url}#{CF.api_version}#{args.first}", args.last.merge!(default_params), :accept => 'json')
      end

      def delete(*args)
        handle_response  RestClient.delete("#{CF.api_url}#{CF.api_version}#{args.first}?api_key=#{CF.api_key}", :accept => 'json')
      end

      def handle_response(response)
        case response.code
        when 401; raise Unauthorized.new
        when 403; raise RateLimitExceeded.new
        when 404; raise NotFound.new
        when 400...500; raise ClientError.new
        when 500...600; raise ServerError.new(response.code)
        else; response
        end

        unless response.length == 2
          parsed_response = JSON.load(response)
          if parsed_response.is_a?(Array)
            parsed_response.map{|item| Hashie::Mash.new(item)}
          else
            new_response = parsed_response.inject({ }) do |x, (k,v)|
                            x[k.sub(/\A_/, '')] = v
                            x
                          end
            Hashie::Mash.new(new_response)
          end
        else
          response
        end
      end
    end
  end
end