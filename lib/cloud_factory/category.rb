module CloudFactory
  class Category
    include Client
    include ClientRequestResponse

    # Id of the specific Category
    attr_accessor :category_id 
    
    # Category name 
    attr_accessor :name
    
    # ==Returns all category
    # ===Usage example
    #   categories = CloudFactory::Category.all
    def self.all
      response = get("/categories.json")
    end
    
    # Returns all lines of a specific category
    def self.get_lines_of_category(category_id)
      @category_id = category_id
      get("/categories/#{@category_id}/lines.json")
    end
  end
end
