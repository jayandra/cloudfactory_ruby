module CF 
  class Account
    include Client

    class << self
      
      # Contains Error message if any
      attr_accessor :errors

      # ==Returns Account Info
      # ===Usage Example:
      #   CF::Account.info
      def info
        resp = get('/account.json')

        if resp.code != 200
          self.errors = resp.error.message
        end
        return resp
      end

      # ==Validation of account
      # ===Usage Example:
      #   CF::Account.valid?
      def valid?
        info
        errors.nil?
      end
      
      # ==Login to CloudFactory app through cloudfactory GEM
      # ===Usage Example:
      #   CF::Account.login("sprout@sprout-technology.com", "password")
      def login(email, passwd)
        resp = post('/account_login.json', :user => {:email => email, :password => passwd})
        resp
      end
    end
  end
end