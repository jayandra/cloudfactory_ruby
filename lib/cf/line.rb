module CF
  class Line
    require 'httparty'
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

    # input_formats contained within line object
    attr_accessor :input_formats
    attr_accessor :errors
    #attr_accessor :input_format_instance
    #attr_accessor :station_instance

    # ==Initializes a new line
    # ==Usage of line.new("line_name")
    #
    #     line = Line.new("Digit", "Survey")
    def initialize(title, department_name, options={})
      @input_formats =[]
      @stations =[]
      @title = title
      @department_name = department_name
      @public = options[:public]
      @description = options[:description]
      resp = self.class.post("/lines/#{CF.account_name}.json", {:line => {:title => title, :department_name => department_name, :public => @public, :description => @description}})
      if resp.code != 200
        self.errors = resp.error
      end
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
        @station_input_formats = stations.station_input_formats
        if type == "Improve" && self.stations.size < 1
          raise ImproveStationNotAllowed.new("You cannot add Improve Station as a first station of a line")
        else
          request_general = 
          {
            :body => 
            {
              :api_key => CF.api_key,
              :station => {:type => type, :input_formats => @station_input_formats}
            }
          }
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
            resp = HTTParty.post("#{CF.api_url}#{CF.api_version}/lines/#{CF.account_name}/#{self.title.downcase}/stations.json",request_general)
          end
          station = CF::Station.new()
          resp.to_hash.each_pair do |k,v|
            station.send("#{k}=",v) if station.respond_to?(k)
          end
          station.line = self
          station.line_title = self.title
          if resp.response.code != "200"
            station.errors = resp.parsed_response['error']
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
      resp = CF::Station.post("/lines/#{self.id}/stations.json", :station => {:type => type})
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
    #     CF::InputFormat.new({:line => line, :label => "image_url", :field_type => "text_data", :value => "http://s3.amazon.com/bizcardarmy/medium/1.jpg", :required => true, :validation_format => "url"})
    #     CF::Station.new({:line => line, :type => "Work"})
    #   end
    #
    # ===OR creating without variable
    #   CF::Line.create("line_name") do
    #     CF::InputFormat.new({:line => self, :label => "image_url", :field_type => "text_data", :value => "http://s3.amazon.com/bizcardarmy/medium/1.jpg", :required => true, :validation_format => "url"})
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

    # ==Usage of line.input_formats(input_format)
    #   line = Line.new("line name", "Survey")
    #
    #   input_format = CF::InputFormat.new({:label => "image_url", :field_type => "text_data", :value => "http://s3.amazon.com/bizcardarmy/medium/1.jpg", :required => true, :validation_format => "url"})
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
          input_format.errors = resp.error.message.first
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
    # ===Syntax for get_line method is
    #   CF::Line.info(line)
    def self.info(line)
      if line.class == CF::Line
        resp = get("/lines/#{CF.account_name}/#{line.title.downcase}.json")
      else
        resp = get("/lines/#{CF.account_name}/#{line.downcase}.json")
      end
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
      get("/lines/#{CF.account_name}.json")
    end
    
    def get_stations
      CF::Station.get("/lines/#{ACCOUNT_NAME}/#{self.title.downcase}/stations.json")
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
      old_title = self.title
      @title = options[:title]
      @department_name = options[:department_name]
      @public = options[:public]
      @description = options[:description]
      self.class.put("/lines/#{CF.account_name}/#{old_title.downcase}.json", :line => {:title => @title, :department_name => @department_name, :public => @public, :description => @description})
    end

    # ==Deletes a line
    # ===Syantax for delete method
    #   line = CF::Line.new("Digitize Card", "Survey")
    #   line.delete
    def destroy
      self.class.delete("/lines/#{CF.account_name}/#{self.title.downcase}.json")
    end
    
    def self.destroy(title)
      delete("/lines/#{CF.account_name}/#{title.downcase}.json")
    end
  end
end