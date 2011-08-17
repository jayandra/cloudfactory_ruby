module CF
  class Line
    require 'httparty'
    include Client

    # Title of the Line
    attr_accessor :title

    # Department Name for Line
    attr_accessor :department_name

    # Public is a boolean attribute which when set to true becomes public & vice-versa
    #
    # Public attribute is optional, by default it's true
    attr_accessor :public

    # Description attribute describes about the line
    #
    # Description attribute is optional
    attr_accessor :description

    # stations contained within line object
    attr_accessor :stations

    # input_formats contained within line object
    attr_accessor :input_formats
    
    # Contains Error Messages
    attr_accessor :errors

    # ==Initializes a new line
    # ==Usage of line.new("line_name")
    #
    #     line = Line.new("line_name", "Survey")
    def initialize(title, department_name, options={})
      @input_formats =[]
      @stations =[]
      @title = title
      @department_name = department_name
      @public = options[:public].present? ? options[:public] : false
      @description = options[:description]
      resp = self.class.post("/lines/#{CF.account_name}.json", {:line => {:title => title, :department_name => department_name, :public => @public, :description => @description}})
      if resp.code != 200
        self.errors = resp.error.message
      end
    end

    # ==Adds station in a line
    # ===Usage Example:
    #   line = CF::Line.new("line_name", "Department_name")
    #   station = CF::Station.new({:type => "Work"})
    #   line.stations station
    #
    # * returns
    # line.stations as an array of stations
    def stations stations = nil
      if stations
        type = stations.type
        @station_input_formats = stations.station_input_formats
        if type == "Improve" && self.stations.size < 1
          raise ImproveStationNotAllowed.new("You cannot add Improve Station as a first station of a line")
        else
          if type == "Tournament"
            @jury_worker = stations.jury_worker
            @auto_judge = stations.auto_judge
            request_tournament = 
            {
              :body => 
              {
                :api_key => CF.api_key,
                :station => {:type => type, :jury_worker => @jury_worker, :auto_judge => @auto_judge, :input_formats => @station_input_formats}
              }
            }
            resp = HTTParty.post("#{CF.api_url}#{CF.api_version}/lines/#{CF.account_name}/#{self.title.downcase}/stations.json",request_tournament)
          else
            request_general = 
            {
              :body => 
              {
                :api_key => CF.api_key,
                :station => {:type => type, :input_formats => @station_input_formats}
              }
            }
            resp = HTTParty.post("#{CF.api_url}#{CF.api_version}/lines/#{CF.account_name}/#{self.title.downcase}/stations.json",request_general)
          end
          station = CF::Station.new()
          resp.to_hash.each_pair do |k,v|
            station.send("#{k}=",v) if station.respond_to?(k)
          end
          station.line = self
          station.line_title = self.title
          if resp.response.code != "200"
            station.errors = resp.parsed_response['error']['message']
          end
          @stations << station
        end
      else
        @stations
      end
    end

    def stations=(stations) # :nodoc:
      @stations << stations
    end

    # ==Initializes a new line
    # ===Usage Example:
    #
    # ===creating Line within block using variable
    #   Line.create("line_name", "Department_name") do |line|
    #     CF::InputFormat.new({:line => line, :label => "image_url", :required => true, :valid_type => "url"})
    #     CF::Station.new({:line => line, :type => "Work"})
    #   end
    #
    # ==OR
    # ===creating without variable
    #   CF::Line.create("line_name", "Department_name") do
    #     CF::InputFormat.new({:line => self, :label => "image_url", :required => true, :valid_type => "url"})
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

    # ==Adds input format in a line
    # ===Usage Example:
    #   line = Line.new("line name", "Survey")
    #
    #   input_format = CF::InputFormat.new({:label => "image_url", :required => true, :valid_type => "url"})
    #   line.input_formats input_format
    # * returns
    # line.input_formats as an array of input_formats
    def input_formats input_formats_value = nil
      if input_formats_value
        name = input_formats_value.name
        required = input_formats_value.required
        valid_type = input_formats_value.valid_type
        resp = CF::InputFormat.post("/lines/#{CF.account_name}/#{self.title.downcase}/input_formats.json", :input_format => {:name => name, :required => required, :valid_type => valid_type})
        input_format = CF::InputFormat.new()
        resp.each_pair do |k,v|
          input_format.send("#{k}=",v) if input_format.respond_to?(k)
        end
        if resp.code != 200
          input_format.errors = resp.error.message
        end
        @input_formats << input_format
      else
        @input_formats
      end
      
    end
    
    def input_formats=(input_formats_value) # :nodoc:
      @input_formats << input_formats_value
    end

    # ==Returns the content of a line by making an Api call
    # ===Usage Example:
    #   CF::Line.info(line)
    # ==OR
    #   CF::Line.info("line_title")
    def self.info(line)
      if line.class == CF::Line
        resp = get("/lines/#{CF.account_name}/#{line.title.downcase}.json")
      else
        resp = get("/lines/#{CF.account_name}/#{line.downcase}.json")
      end
    end

    # ==Finds a line
    # ===Usage Example:
    #   CF::Line.find(line)
    # ==OR
    #   CF::Line.find("line_title")
    def self.find(line)
      if line.class == CF::Line
        resp = get("/lines/#{CF.account_name}/#{line.title.downcase}.json")
      else
        resp = get("/lines/#{CF.account_name}/#{line.downcase}.json")
      end
    end
    
    # ==Returns all the lines of an account
    # ===Syntax for all method is
    #   CF::Line.all
    def self.all
      get("/lines/#{CF.account_name}.json")
    end
    
    # ==Returns all the stations of a line
    # ===Usage Example:
    #   CF::Line.get_stations
    def get_stations
      CF::Station.get("/lines/#{ACCOUNT_NAME}/#{self.title.downcase}/stations.json")
    end
    # ==Return all the public lines
    # ===Usage Example:
    #   CF::Line.public_lines
    def self.public_lines
      get("/public_lines.json")
    end

    # ==Updates a line
    # ===Syntax for update method is
    #   line = CF::Line.new("Digitize Card", "Survey")
    #   line.update({:title => "New Title"})
    # * This changes the title of the "line" object from "Digitize Card" to "New Title"
    def update(options={}) # :nodoc:
      old_title = self.title
      @title = options[:title]
      @department_name = options[:department_name]
      @public = options[:public]
      @description = options[:description]
      self.class.put("/lines/#{CF.account_name}/#{old_title.downcase}.json", :line => {:title => @title, :department_name => @department_name, :public => @public, :description => @description})
    end

    # ==Deletes a line
    # ===Usage Example:
    #   line = CF::Line.new("Digitize Card", "Survey")
    #   line.destroy
    def destroy(options={})
      force = options[:force]
      if !force.nil?
        resp = self.class.delete("/lines/#{CF.account_name}/#{self.title.downcase}.json", :forced => force)
      else
        resp = self.class.delete("/lines/#{CF.account_name}/#{self.title.downcase}.json")
      end
      if resp.code != 200
        self.errors = resp.errors.message
      end
      return resp
    end
    
    # ==Deletes a line by passing it's title
    # ===Usage Example:
    #   line = CF::Line.new("line_title", "Survey")
    #   CF::Line.destroy("line_title")
    def self.destroy(title, options={})
      forced = options[:forced]
      if forced
        resp = delete("/lines/#{CF.account_name}/#{title.downcase}.json", {:forced => forced})
      else
        resp = delete("/lines/#{CF.account_name}/#{title.downcase}.json")
      end
    end
  end
end