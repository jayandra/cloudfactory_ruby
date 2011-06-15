module CF
  class Station
    include Client

    # type of the station, e.g. station = Station.new(line, {:type => "Work"})
    attr_accessor :type

    # line attribute is parent attribute for station & is required for making Api call
    attr_accessor :line_id

    # ID of the station
    attr_accessor :id

    # ==Initializes a new station
    # ===Usage Example
    #   line = CF::Line.new("Digitize", "Survey")
    #   station = CF::Station.new({:line => line, :type => "Work"})
    def initialize(options={})
      @input_headers =[]
      @line_id = options[:line].nil? ? nil : options[:line].id
      @type = options[:type].nil? ? nil : options[:type].camelize
      @max_judges = options[:max_judges]
      @auto_judge = options[:auto_judge]
      @line = options[:line]
      if @line_id
        if @type == "Tournament"
          resp = self.class.post("/lines/#{@line_id}/stations.json", :station => {:type => @type, :line_id => @line_id, :jury_worker => {:max_judges => @max_judges}, :auto_judge => {:enabled => @auto_judge }})
          @id = resp.id
          resp.to_hash.each_pair do |k,v|
            self.send("#{k}=",v) if self.respond_to?(k)
          end
          @line.stations = self
        else
          resp = self.class.post("/lines/#{@line_id}/stations.json", :station => {:type => @type})
          @id = resp.id
          resp.to_hash.each_pair do |k,v|
            self.send("#{k}=",v) if self.respond_to?(k)
          end
          @line.stations = self
        end
      end
    end

    # ==Initializes a new station within block
    # ===Usage Example
    # ===Creating station using block variable
    #   line = CF::Line.create("Digitize Card","Digitization") do |l|
    #     CF::InputHeader.new({:line => l, :label => "Company", :field_type => "text_data", :value => "Google", :required => true, :validation_format => "general"})
    #     CF::InputHeader.new({:line => l, :label => "Website", :field_type => "text_data", :value => "www.google.com", :required => true, :validation_format => "url"})
    #     CF::Station.create({:line => l, :type => "work") do |s|
    #       CF::HumanWorker.new({:station => s, :number => 1, :reward => 20)
    #       CF::Form.create({:station => s, :title => "Enter text from a business card image", :description => "Describe"}) do |i|
    #         CF::FormField.new({:instruction => i, :label => "First Name", :field_type => "SA", :required => "true"})
    #         CF::FormField.new({:instruction => i, :label => "Middle Name", :field_type => "SA"})
    #         CF::FormField.new({:instruction => i, :label => "Last Name", :field_type => "SA", :required => "true"})
    #       end
    #     end
    #   end
    #
    # ===OR creating without variable within block
    #   line = CF::Line.create("Digitize Card","Digitization") do
    #     CF::InputHeader.new({:line => self, :label => "Company", :field_type => "text_data", :value => "Google", :required => true, :validation_format => "general"})
    #     CF::InputHeader.new({:line => self, :label => "Website", :field_type => "text_data", :value => "www.google.com", :required => true, :validation_format => "url"})
    #     CF::Station.create({:line => self, :type => "work") do
    #       CF::HumanWorker.new({:station => self, :number => 1, :reward => 20)
    #       CF::Form.create({:station => self, :title => "Enter text from a business card image", :description => "Describe"}) do
    #         CF::FormField.new({:instruction => self, :label => "First Name", :field_type => "SA", :required => "true"})
    #         CF::FormField.new({:instruction => self, :label => "Middle Name", :field_type => "SA"})
    #         CF::FormField.new({:instruction => self, :label => "Last Name", :field_type => "SA", :required => "true"})
    #       end
    #     end
    #   end
    def self.create(options, &block)
      station = Station.new(options)
      if block.arity >= 1
        block.call(station)
      else
        station.instance_eval &block
      end
      station
    end

    # ==Creates new instruction for station object
    # ===Usage of worker method for "station" object
    #   line = CF::Line.new("line name", "Survey")
    #   station = CF::Station.new({:type => "work"})
    #   line.stations station
    #   human_worker = CF::HumanWorker.new({:number => 1, :reawrd => 20})
    #   line.stations.first.worker human_worker
    def worker worker_instance = nil
      if worker_instance
        @worker_instance = worker_instance
      else
        @worker_instance
      end
    end

    def worker=(worker_instance) # :nodoc:
      worker_type = worker_instance.class.to_s.split("::").last
      case worker_type
      when "HumanWorker"
        if worker_instance.station
          @worker_instance = worker_instance
        else
          number = worker_instance.number
          reward = worker_instance.reward
          resp = CF::HumanWorker.post("/stations/#{self.id}/workers.json", :worker => {:number => number, :reward => reward, :type => "HumanWorker"})
          worker = CF::HumanWorker.new({})
          resp.to_hash.each_pair do |k,v|
            worker.send("#{k}=",v) if worker.respond_to?(k)
          end
          @worker_instance = worker
        end

      else
        if worker_instance.station
          @worker_instance = worker_instance 
        else
          @number = worker_instance.number.nil? ? 1 : worker_instance.number
          @reward = worker_instance.reward.nil? ? 0 : worker_instance.reward
          resp = worker_instance.class.post("/stations/#{self.id}/workers.json", :body => {:worker => {:number => @number, :reward => @reward, :type => type}})
          worker = worker_instance.class.new({})
          resp.to_hash.each_pair do |k,v|
            worker.send("#{k}=",v) if worker.respond_to?(k)
          end
          @worker_instance = worker
        end
      end
    end

    # ==Creates new instruction for station object
    # ===Usage of Instruction method for "station" object
    #   line = CF::Line.new("line name", "Survey")
    #   station = CF::Station.new({:type => "work"})
    #   line.stations station
    #   standard_instruction = CF::Form.new({:title => "title", :description => "description"})
    #   line.stations.first.instruction instruction
    def instruction instruction_instance = nil
      if instruction_instance
        @instruction_instance = instruction_instance
      else
        @instruction_instance
      end
    end
    
    def instruction=(instruction_instance) # :nodoc:
      temp_instruction = instruction_instance
      if instruction_instance.class == Hash
        form_type = instruction_instance['_type']
        @instruction = eval(form_type.camelize).new({})
        instruction_instance.to_hash.each_pair do |k,v|
          @instruction.send("#{k}=",v) if @instruction.respond_to?(k)
        end
      else
        @instruction = instruction_instance
      end
      if @instruction.station
        @instruction_instance = @instruction
      else
        @title = @instruction.title
        @description = @instruction.description
        type = @instruction.class.to_s.split("::").last
        form = @instruction.class.new({})
        if type == "CustomForm"
          @html = @instruction.raw_html
          @css = @instruction.raw_css
          @javascript = @instruction.raw_javascript
          @resp = CF::CustomForm.post("/stations/#{self.id}/instruction.json", :instruction => {:title => @title, :description => @description, :_type => "CustomForm", :raw_html => @html, :raw_css => @css, :raw_javascript => @javascript})
        else
          @resp = CF::Form.post("/stations/#{self.id}/instruction.json", :instruction => {:title => @title, :description => @description, :_type => type}) 
        end
        
        @resp.to_hash.each_pair do |k,v|
          form.send("#{k}=",v) if form.respond_to?(k)
        end
        
        form.station = self
        @instruction_instance = form
      end
    end

    # ==Usage of line.input_headers(input_header)
    #   line = CF::Line.new("line name", "Survey")
    #   station = CF::Station.new({:type => "work"})
    #   line.stations station
    #   input_header = CF::InputHeader.new({:line => l, :label => "Website", :field_type => "text_data", :value => "www.google.com", :required => true, :validation_format => "url"})
    #   line.stations.first.input_headers input_header
    # * returns
    # line.stationss.first.input_headers as an array of input_headers
    def input_headers input_headers_value = nil
      if input_headers_value
        label = input_headers_value.label
        field_type = input_headers_value.field_type
        value = input_headers_value.value
        required = input_headers_value.required
        validation_format = input_headers_value.validation_format
        resp = CF::InputHeader.post("/lines/#{self.line_id}/input_headers.json", :input_header => {:label => label, :field_type => field_type, :value => value, :required => required, :validation_format => validation_format})

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
    # ==Updates Standard Instruction of a station
    # ===Usage example
    #   line = CF::Line.create("Digitize Card","Digitization") do |l|
    #     CF::Station.create({:line => l, :type => "work") do |s|
    #       CF::HumanWorker.new({:station => s, :number => 1, :reward => 20)
    #     end
    #   end
    #   line.stations[0].update_instruction({:title => "Enter phone number from a business card image", :description => "Call"})
    def update_instruction(options={})
      @title       = options[:title]
      @description = options[:description]
      self.class.put("/stations/#{self.id}/instruction.json", :instruction => {:title => @title, :description => @description, :type => "Form"})
    end

    # ==Returns a particular station of a line
    # ===Usage example for get_station() method
    #   line = CF::Line.create("Digitize Card", "4dc8ad6572f8be0600000001")
    #   station = CF::Station.new({:line => line, :type => "Work"})
    #   line.stations station
    #
    #   got_station = line.stations[0].get
    # returns the station object
    def get
      self.class.get("/lines/#{self.line_id}/stations/#{self.id}.json")
    end

    # ==Returns information of instruction
    # ===Usage example
    #   line = CF::Line.create("Digitize Card","Digitization") do |l|
    #     CF::InputHeader.new({:line => l, :label => "Company", :field_type => "text_data", :value => "Google", :required => true, :validation_format => "general"})
    #     CF::InputHeader.new({:line => l, :label => "Website", :field_type => "text_data", :value => "www.google.com", :required => true, :validation_format => "url"})
    #     CF::Station.create({:line => l, :type => "work") do |s|
    #       CF::HumanWorker.new({:station => s, :number => 1, :reward => 20)
    #       CF::Form.create({:station => s, :title => "Enter text from a business card image", :description => "Describe"}) do |i|
    #         CF::FormField.new({:instruction => i, :label => "First Name", :field_type => "SA", :required => "true"})
    #         CF::FormField.new({:instruction => i, :label => "Middle Name", :field_type => "SA"})
    #         CF::FormField.new({:instruction => i, :label => "Last Name", :field_type => "SA", :required => "true"})
    #       end
    #     end
    #   end
    #
    #   @got_instruction = line.stations[0].get_instruction
    def get_instruction
      self.class.get("/stations/#{self.id}/instruction.json")
    end

    # ==Returns all the stations associated with a particular line
    # ===Usage example for station.all method is
    #   line = CF::Line.create("Digitize Card","Digitization") do |l|
    #     CF::InputHeader.new({:line => l, :label => "Company", :field_type => "text_data", :value => "Google", :required => true, :validation_format => "general"})
    #     CF::InputHeader.new({:line => l, :label => "Website", :field_type => "text_data", :value => "www.google.com", :required => true, :validation_format => "url"})
    #     CF::Station.create({:line => l, :type => "work") do |s|
    #       CF::HumanWorker.new({:station => s, :number => 1, :reward => 20)
    #       CF::Form.create({:station => s, :title => "Enter text from a business card image", :description => "Describe"}) do |i|
    #         CF::FormField.new({:instruction => i, :label => "First Name", :field_type => "SA", :required => "true"})
    #         CF::FormField.new({:instruction => i, :label => "Middle Name", :field_type => "SA"})
    #         CF::FormField.new({:instruction => i, :label => "Last Name", :field_type => "SA", :required => "true"})
    #       end
    #     end
    #   end
    #
    #   CF::Station.all(line)
    # returns all stations
    def self.all(line)
      get("/lines/#{line.id}/stations.json")
    end

    # ==Deletes a station
    # * We need to pass line object with which desired station associated with as an argument to delete a station
    # ===Usage example for delete method
    #   line = CF::Line.new("Digitize Card", "4dc8ad6572f8be0600000001")
    #   station = CF::Station.new({:line =. line, :type => "Work"})
    #   line.stations station
    #
    #   station.delete
    def delete
      self.class.delete("/lines/#{self.line_id}/stations/#{self.id}.json")
    end
  end
end