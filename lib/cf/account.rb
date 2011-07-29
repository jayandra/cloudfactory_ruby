module CF
  class Account
    include Client
    
    def self.info
      get('/account.json')
    end
    
  end
end