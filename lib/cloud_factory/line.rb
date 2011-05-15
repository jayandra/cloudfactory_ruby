module CloudFactory
  class Line
    include Client
    include ClientRequestResponse
    
    # Title of the Line
    attr_accessor :title
    
    # Category Id is required for the category which is categorized according to ID, e.g. "4dc8ad6572f8be0600000001"
    attr_accessor :category_id
    
    # Public is a boolean attribute which when set to true becomes public & vice-versa
    #
    # Public attribute is optional
    attr_accessor :public
    
    # Description attribute describes about the line
    #
    # this attribute is also optional
    attr_accessor :description
    
    # id attribute is for the line_id & is required to be stored for making Api calls
    attr_accessor :id
    
    # station_id is required to be stored for making Api calls
    attr_accessor :station_id

    #attr_accessor :input_header_instance
    #attr_accessor :station_instance

    # ==Initializes a new line
    # ==Usage of line.new("line_name")
    #
    #     line = Line.new("Digit")
    

    def initialize(title, category_id, options={})
      @title = title
      @category_id = category_id
      @public = options[:public]
      @description = options[:description]
      resp = self.class.post("/lines.json", :body => {:line => {:title => title, :category_id => category_id, :public => @public, :description => @description}})
      self.id = resp._id
    end
    
    # ==Usage of line.input_headers(input_header)
    #     line = Line.new("line name")
    #     line.input_headers = InputHeader.new
    # returns 
    #     line.input_headers
    def input_headers input_headers_value = nil
      if input_headers_value
        @input_headers_value = input_headers_value
      else
        @input_headers_value
      end
    end
    def input_headers=(input_headers_value) # :nodoc:
      @input_headers_value = input_headers_value
    end
    
    # ==Usage of line.stations << station
    #     line = Line.new("line name")
    #     station = Station.new("station_name")
    #     line.stations << station
    # returns 
    #     line.stations
    def stations stations = nil
      resp = self.class.post("/lines/#{id}/stations.json", :body => {:station => {:type => "Work"}})
      @station_id = resp._id
      if stations
        @stations << stations
      else
        @stations
      end
    end
    def stations=(stations) # :nodoc:
      resp = self.class.post("/lines/#{id}/stations.json", :body => {:station => {:type => "Work"}})
      @station_id = resp._id
      @stations = stations
    end
    # ==Initializes a new line
    # ==Usage of line.create("line_name") do |block|
    # ===creating Line within block using variable
    #     attrs = {:label => "image_url",
    #       :field_type => "text_data",
    #       :value => "http://s3.amazon.com/bizcardarmy/medium/1.jpg",
    #       :required => true,
    #       :validation_format => "url"
    #     } 
    #
    #     input_header = InputHeader.new(attrs)
    #
    #     Line.create("line_name") do |line|
    #       line.input_headers = [input_header]
    #     end
    # 
    # ===OR creating without variable
    #     attrs = {:label => "image_url",
    #       :field_type => "text_data",
    #       :value => "http://s3.amazon.com/bizcardarmy/medium/1.jpg",
    #       :required => true,
    #       :validation_format => "url"} 
    #
    #     input_header = InputHeader.new(attrs)
    #
    #     Line.create("line_name") do
    #       input_headers  [input_header]
    #     end
    def self.create(title, category_id, options={}, &block)
      line = Line.new(title,category_id,options={})
      @public = options[:public]
      @description = options[:description]
      if block.arity >= 1
        block.call(line)
      else
        line.instance_eval &block
      end
      resp = post("/lines.json", :body => {:line => {:title => title, :category_id => category_id, :public => @public, :description => @description}})
      line
    end
    
    # ==Returns the content of a line by making an Api call
    # ===Syntax for get_line method is 
    #   CloudFactory::Line.get_line(line)
    def self.get_line(line)
      get("/lines/#{line.id}.json")
    end
    
    # ==Returns all the lines of an account
    # ===Syntax for my_lines method is 
    #   CloudFactory::Line.my_lines
    def self.my_lines
      get("/lines.json", :body => {:public => false})
    end
    
    # ==Return all the lines whose public value is set true
    # ===Syntax for public_lines method is 
    #   CloudFactory::Line.public_lines(line)
    def self.public_lines
      get("/lines.json", :body => {:public => true})
    end
    
    # ==Updates a line 
    # ===Syntax for update method is 
    #   line = CloudFactory::Line.new("Digitize Card", "4dc8ad6572f8be0600000001", {:public => true, :description => "this is description"})
    #   line.update({:title => "New Title"})
    # ===This changes the title of the "line" object from "Digitize Card" to "New Title"
    def update(options={})
      @title = options[:title]
      @category_id = options[:category_id]
      @public = options[:public]
      @description = options[:description]
      self.class.put("/lines/#{id}.json", :body => {:line => {:title => @title, :category_id => @category_id, :public => @public, :description => @description}})
    end
    
    # ==Deletes a line
    # ===Syantax for delete method
    #   line = CloudFactory::Line.new("Digitize Card", "4dc8ad6572f8be0600000001", {:public => true, :description => "this is description"})
    #   line.delete
    def delete
      self.class.delete("/lines/#{id}.json")
    end
  end
end