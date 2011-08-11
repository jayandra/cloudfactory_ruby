module CF
  class Department
    include Client
    
    # Department name 
    attr_accessor :name
    
    # ==Returns all Department
    # ===Usage example
    #   categories = CF::Department.all
    def self.all
      response = get("/departments.json")
    end
  end
end
