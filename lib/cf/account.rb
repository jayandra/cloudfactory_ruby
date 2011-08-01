module CF
  class Account
    include Client

    class << self
      attr_accessor :errors

      def info
        resp = get('/account.json')

        if resp.code != 200
          self.errors = resp.error.message
        end

      end

      def valid?
        info
        errors.nil?
      end
    end
  end
end