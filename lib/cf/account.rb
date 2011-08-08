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
        return resp
      end

      def valid?
        info
        errors.nil?
      end
      
      def login(email, passwd)
        resp = post('/account_login.json', :user => {:email => email, :password => passwd})
        resp
      end
    end
  end
end