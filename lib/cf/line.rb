module CF
  class Line
    include Client

    # Title of the Line
    attr_accessor :title

    # Category Name is required for the category which is categorized according to ID, e.g. "4dc8ad6572f8be0600000001"
    attr_accessor :department_name

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

    # stations contained within line object
    attr_accessor :stations

    # input_headers contained within line object
    attr_accessor :input_headers
    #attr_accessor :input_header_instance
    #attr_accessor :station_instance

    # ==Initializes a new line
    # ==Usage of line.new("line_name")
    #
    #     line = Line.new("Digit", "Survey")

    def initialize(title, department_name, options={})
      @input_headers =[]
      @stations =[]
      @title = title
      @department_name = department_name
      @public = options[:public]
      @description = options[:description]
      resp = self.class.post("/lines.json", {:line => {:title => title, :department_name => department_name, :public => @public, :description => @description}})
      self.id = resp.id
    end

    # ==Usage of line.stations << station
    #   line = CF::Line.new("line name")
    #   station = CF::Station.new({:type => "Work"})
    #   line.stations station
    #
    # * returns
    # line.stations as an array of stations
    def stations stations = nil
      if stations
        type = stations.type
        if type == "Improve" && self.stations.size <= 1
          raise ImproveStationNotAllowed.new("You cannot add Improve Station as a first station of a line")
        else
          resp = CF::Station.post("/lines/#{id}/stations.json", :station => {:type => type})
          station = CF::Station.new()
          resp.to_hash.each_pair do |k,v|
            station.send("#{k}=",v) if station.respond_to?(k)
          end
          @stations << station
        end
      else
        @stations
      end
    end

    def << stations #:nodoc:
      type = stations.type
      @stations << stations
      resp = CF::Station.post("/lines/#{id}/stations.json", :station => {:type => type})
    end


    def stations=(stations) # :nodoc:
      @stations << stations
      #resp = CF::Station.post("/lines/#{id}/stations.json", :station => {:type => stations.type})
      #@station_id = resp._id
    end

    # ==Initializes a new line
    # ==Usage of line.create("line_name") do |block|
    # ===creating Line within block using variable
    #   Line.create("line_name") do |line|
    #     CF::InputHeader.new({:line => line, :label => "image_url", :field_type => "text_data", :value => "http://s3.amazon.com/bizcardarmy/medium/1.jpg", :required => true, :validation_format => "url"})
    #     CF::Station.new({:line => line, :type => "Work"})
    #   end
    #
    # ===OR creating without variable
    #   CF::Line.create("line_name") do
    #     CF::InputHeader.new({:line => self, :label => "image_url", :field_type => "text_data", :value => "http://s3.amazon.com/bizcardarmy/medium/1.jpg", :required => true, :validation_format => "url"})
    #     CF::Station.new({:line => self, :type => "Work"})
    #   end
    def self.create(title, department_name, options={}, &block)
      line = Line.new(title,department_name,options={})
      @public = options[:public]
      @description = options[:description]
      if block.arity >= 1
        block.call(line)
      else
        line.instance_eval &block
      end
      line
    end

    # ==Usage of line.input_headers(input_header)
    #   line = Line.new("line name", "Survey")
    #
    #   input_header = CF::InputHeader.new({:label => "image_url", :field_type => "text_data", :value => "http://s3.amazon.com/bizcardarmy/medium/1.jpg", :required => true, :validation_format => "url"})
    #   line.input_headers input_header
    # * returns
    # line.input_headers as an array of input_headers
    def input_headers input_headers_value = nil
      if input_headers_value
        label = input_headers_value.label
        field_type = input_headers_value.field_type
        value = input_headers_value.value
        required = input_headers_value.required
        validation_format = input_headers_value.validation_format
        resp = CF::InputHeader.post("/lines/#{self.id}/input_headers.json", :input_header => {:label => label, :field_type => field_type, :value => value, :required => required, :validation_format => validation_format})
        input_header = CF::InputHeader.new()
        resp.to_hash.each_pair do |k,v|
          input_header.send("#{k}=",v) if input_header.respond_to?(k)
        end
        @input_headers << input_header
      else
        @input_headers
      end
    end
    def input_headers=(input_headers_value) # :nodoc:
      @input_headers << input_headers_value
    end

    # ==Returns the content of a line by making an Api call
    # ===Syntax for get_line method is
    #   CF::Line.info(line)
    def self.info(line)
      get("/lines/#{line.id}.json")
    end

    # ==Finds a line
    # ===Syntax for find method is
    #   CF::Line.find(line.id)
    def self.find(line_id)
      get("/lines/#{line_id}.json")
    end
    # ==Returns all the lines of an account
    # ===Syntax for all method is
    #   CF::Line.all
    def self.all
      get("/lines.json")
    end

    # ==Return all the lines whose public value is set true
    # ===Syntax for public_lines method is
    #   CF::Line.public_lines
    def self.public_lines
      get("/public_lines.json")
    end

    # ==Updates a line
    # ===Syntax for update method is
    #   line = CF::Line.new("Digitize Card", "Survey")
    #   line.update({:title => "New Title"})
    # * This changes the title of the "line" object from "Digitize Card" to "New Title"
    def update(options={})
      @title = options[:title]
      @department_name = options[:department_name]
      @public = options[:public]
      @description = options[:description]
      self.class.put("/lines/#{id}.json", :line => {:title => @title, :department_name => @department_name, :public => @public, :description => @description})
    end

    # ==Deletes a line
    # ===Syantax for delete method
    #   line = CF::Line.new("Digitize Card", "Survey")
    #   line.delete
    def delete
      self.class.delete("/lines/#{id}.json")
    end
  end
end