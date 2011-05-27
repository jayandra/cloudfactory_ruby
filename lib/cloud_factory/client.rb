module CloudFactory
  module Client
    extend ActiveSupport::Concern
    
    included do |base|
      base.send(:include, HTTParty)
      base.send(:base_uri, "manishlaldas.lvh.me:3000/api/v1")
      base.send(:headers, "accept" => "application/json")
      base.send(:format, :json)
      base.send(:default_params, {:api_key => "5c99665131ad4044968de3ca0b984c8c0d45e9a2", :email => "manish.das@sprout-technology.com"})
      # base.extend(ClassMethods)
    end
    
    # def subscriptions(query={})
    #   self.class.get("/users/subscriptions.json", :query => query)
    # end
    
    
    module ClassMethods
    # class << self
      def get(*args); handle_response super end

      def post(*args); handle_response super end
    
      def handle_response(response)
        case response.code
        when 401; raise Unauthorized.new
        when 403; raise RateLimitExceeded.new
        when 404; raise NotFound.new
        when 400...500; raise ClientError.new
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