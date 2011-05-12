module CloudFactory
  class Category
    include Client
    include ClientRequestResponse
    
    # Title of the Line
    attr_accessor :category_id, :name
    def self.all
      response = get("/categories.json")
    end
    
    def self.get_lines_of_category(category_id)
      @category_id = category_id
      get("/categories/#{@category_id}/lines.json")
    end
  end
end
