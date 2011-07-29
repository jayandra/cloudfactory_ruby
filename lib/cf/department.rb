module CF
  class Department
    include Client

    # Id of the specific Category
    attr_accessor :department_name
    
    # Category name 
    attr_accessor :name
    
    # ==Returns all Department
    # ===Usage example
    #   categories = CF::Department.all
    def self.all
      response = get("/departments.json")
    end
    
    # Returns all lines of a specific Department
    def self.get_lines_of_department(department_name)
      @department_name = department_name
      get("/departments/#{@department_name}.json")
    end
  end
end
