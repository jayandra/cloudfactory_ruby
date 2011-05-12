module CloudFactory
  class Category
    include Client
    include ClientRequestResponse
    
    # Title of the Line
    attr_accessor :id, :name
    def self.all
      debugger
      response = get("/categories.json")
    end
  end
end
