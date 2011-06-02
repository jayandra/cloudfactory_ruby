module CloudFactory
  class Line
    include Client
    
    # Title of the Line
    attr_accessor :title
    
    # Category Name is required for the category which is categorized according to ID, e.g. "4dc8ad6572f8be0600000001"
    attr_accessor :category_name
    
    # Public is a boolean attribute which when set to true becomes public & vice-versa
    #
    # Public attribute is optional
    attr_accessor :public
    
    # Description attribute describes about the line
    #
    # Description attribute is optional
    attr_accessor :description
    
    # id attribute is for the line_id & is required to be stored for making Api calls
    attr_accessor :id
    
    # station_id is required to be stored for making Api calls
    attr_accessor :station_id
    attr_accessor :stations, :type
    #attr_accessor :input_headers 
    #attr_accessor :input_header_instance
    #attr_accessor :station_instance

    # ==Initializes a new line
    # ==Usage of line.new("line_name")
    #
    #     line = Line.new("Digit", "Survey")

    def initialize(title, category_name, options={})
      @stations =[]
      @title = title
      @category_name = category_name
      @public = options[:public]
      @description = options[:description]
      resp = self.class.post("/lines.json", {:line => {:title => title, :category_name => category_name, :public => @public, :description => @description}})
      self.id = resp.id
    end
    
    # ==Usage of line.stations << station
    #     line = Line.new("line name")
    #     Station.new(line,{:type => "Work"})
    # 
    # * returns 
    # line.stations as an array of stations
    def stations stations = nil
      if stations
        @type = stations.type
        resp = CloudFactory::Station.post("/lines/#{id}/stations.json", :station => {:type => @type})
        station = CloudFactory::Station.new()
        resp.to_hash.each_pair do |k,v|
          station.send("#{k}=",v) if station.respond_to?(k)
        end
        @stations << station
        #@station_id = resp.id
      else
        @stations
      end
    end
    
    def << stations
      @type = stations.type
      @stations << stations
      resp = CloudFactory::Station.post("/lines/#{id}/stations.json", :station => {:type => @type})
      
      @station_id = resp.id
    end
    
    
    def stations=(stations) # :nodoc:
      @stations << stations
      #resp = CloudFactory::Station.post("/lines/#{id}/stations.json", :station => {:type => stations.type})
      #@station_id = resp._id
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
    #     Line.create("line_name") do |line|
    #       input_header = InputHeader.new(line, attrs)
    #       Station.new(line, {:type => "Work"})
    #     end
    # 
    # ===OR creating without variable
    #     attrs = {:label => "image_url",
    #       :field_type => "text_data",
    #       :value => "http://s3.amazon.com/bizcardarmy/medium/1.jpg",
    #       :required => true,
    #       :validation_format => "url"} 
    #
    #     Line.create("line_name") do
    #       input_header = InputHeader.new(self, attrs)
    #       Station.new(self, {:type => "Work"})
    #     end
    def self.create(title, category_name, options={}, &block)
      line = Line.new(title,category_name,options={})
      @public = options[:public]
      @description = options[:description]
      if block.arity >= 1
        block.call(line)
      else
        line.instance_eval &block
      end
      # resp = post("/lines.json", :body => {:line => {:title => title, :category_name => category_name, :public => @public, :description => @description}})
      line
    end
    
    # ==Returns the content of a line by making an Api call
    # ===Syntax for get_line method is 
    #   CloudFactory::Line.info(line)
    def self.info(line)
      get("/lines/#{line.id}.json")
    end
    
    def self.find(line_id)
      get("/lines/#{line_id}.json")
    end
    # ==Returns all the lines of an account
    # ===Syntax for my_lines method is 
    #   CloudFactory::Line.all
    def self.all
      get("/lines.json")
    end
    
    # ==Return all the lines whose public value is set true
    # ===Syntax for public_lines method is 
    #   CloudFactory::Line.public
    def self.public_lines
      get("/public_lines.json")
    end
    
    # ==Updates a line 
    # ===Syntax for update method is 
    #   line = CloudFactory::Line.new("Digitize Card", "4dc8ad6572f8be0600000001", {:public => true, :description => "this is description"})
    #   line.update({:title => "New Title"})
    # ===This changes the title of the "line" object from "Digitize Card" to "New Title"
    def update(options={})
      @title = options[:title]
      @category_name = options[:category_name]
      @public = options[:public]
      @description = options[:description]
      self.class.put("/lines/#{id}.json", :line => {:title => @title, :category_name => @category_name, :public => @public, :description => @description})
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