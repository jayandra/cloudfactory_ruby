module CF
  class Station
    include Client

    # type of the station, e.g. station = Station.new(line, {:type => "Work"})
    attr_accessor :type

    # line attribute is parent attribute for station & is required for making Api call
    attr_accessor :line_title

    # ID of the station
    attr_accessor :id, :extra, :except, :index, :line
    
    # ==Initializes a new station
    # ===Usage Example
    #   line = CF::Line.new("Digitize", "Survey")
    #   station = CF::Station.new({:line => line, :type => "Work"})
    def initialize(options={})
      @input_formats =[]
      @line_title = options[:line].nil? ? nil : options[:line].title
      @type = options[:type].nil? ? nil : options[:type].camelize
      @max_judges = options[:max_judges]
      @auto_judge = options[:auto_judge]
      @except = options[:input_formats][:except] if options[:input_formats].presence != nil
      @extra = options[:input_formats][:extra] if options[:input_formats].presence != nil
      @line_instance = options[:line]
      if @line_title
        if @type == "Improve"
          line = options[:line]
          if line.stations.size < 1
            raise ImproveStationNotAllowed.new("You cannot add Improve Station as a first station of a line")
          else
            resp = self.class.post("/lines/#{CF.account_name}/#{@line_instance.title.downcase}/stations.json", :station => {:type => @type, :input_formats => {:except => @except, :extra => @extra}})
            resp.to_hash.each_pair do |k,v|
              self.send("#{k}=",v) if self.respond_to?(k)
            end
            @line_instance.stations = self
          end
        elsif @type == "Tournament"
          resp = self.class.post("/lines/#{CF.account_name}/#{@line_instance.title.downcase}/stations.json", :station => {:type => @type, :jury_worker => {:max_judges => @max_judges}, :auto_judge => {:enabled => @auto_judge }, :input_formats => {:except => @except, :extra => @extra}})
          resp.to_hash.each_pair do |k,v|
            self.send("#{k}=",v) if self.respond_to?(k)
          end
          @line_instance.stations = self
        else
          resp = self.class.post("/lines/#{CF.account_name}/#{@line_instance.title.downcase}/stations.json", :station => {:type => @type, :input_formats => {:except => @except, :extra => @extra}})
          resp.to_hash.each_pair do |k,v|
            self.send("#{k}=",v) if self.respond_to?(k)
          end
          @line_instance.stations = self
        end
      end
    end

    # ==Initializes a new station within block
    # ===Usage Example
    # ===Creating station using block variable
    #   line = CF::Line.create("Digitize Card","Digitization") do |l|
    #     CF::InputFormat.new({:line => l, :label => "Company", :field_type => "text_data", :value => "Google", :required => true, :validation_format => "general"})
    #     CF::InputFormat.new({:line => l, :label => "Website", :field_type => "text_data", :value => "www.google.com", :required => true, :validation_format => "url"})
    #     CF::Station.create({:line => l, :type => "work") do |s|
    #       CF::HumanWorker.new({:station => s, :number => 1, :reward => 20)
    #       CF::Form.create({:station => s, :title => "Enter text from a business card image", :description => "Describe"}) do |i|
    #         CF::FormField.new({:form => i, :label => "First Name", :field_type => "SA", :required => "true"})
    #         CF::FormField.new({:form => i, :label => "Middle Name", :field_type => "SA"})
    #         CF::FormField.new({:form => i, :label => "Last Name", :field_type => "SA", :required => "true"})
    #       end
    #     end
    #   end
    #
    # ===OR creating without variable within block
    #   line = CF::Line.create("Digitize Card","Digitization") do
    #     CF::InputFormat.new({:line => self, :label => "Company", :field_type => "text_data", :value => "Google", :required => true, :validation_format => "general"})
    #     CF::InputFormat.new({:line => self, :label => "Website", :field_type => "text_data", :value => "www.google.com", :required => true, :validation_format => "url"})
    #     CF::Station.create({:line => self, :type => "work") do
    #       CF::HumanWorker.new({:station => self, :number => 1, :reward => 20)
    #       CF::Form.create({:station => self, :title => "Enter text from a business card image", :description => "Describe"}) do
    #         CF::FormField.new({:form => self, :label => "First Name", :field_type => "SA", :required => "true"})
    #         CF::FormField.new({:form => self, :label => "Middle Name", :field_type => "SA"})
    #         CF::FormField.new({:form => self, :label => "Last Name", :field_type => "SA", :required => "true"})
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

    # ==Creates new form for station object
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
          resp = CF::HumanWorker.post("/lines/#{CF.account_name}/#{self.line_title.downcase}/stations/#{self.index}/workers.json", :worker => {:number => number, :reward => reward, :type => "HumanWorker"})
          worker = CF::HumanWorker.new({})
          resp.to_hash.each_pair do |k,v|
            worker.send("#{k}=",v) if worker.respond_to?(k)
          end
          @worker_instance = worker
        end

      when "GoogleTranslateRobot"
        if worker_instance.station
          @worker_instance = worker_instance
        else
          @data = worker_instance.data
          @from = worker_instance.from
          @to = worker_instance.to
          resp = CF::GoogleTranslateRobot.post("/lines/#{CF.account_name}/#{self.line_title.downcase}/stations/#{self.index}/workers.json", :worker => {:number => 1, :reward => 0, :type => "google_translate_robot", :data => @data, :from => @from, :to => @to})
          worker = CF::GoogleTranslateRobot.new({})
          resp.to_hash.each_pair do |k,v|
            worker.send("#{k}=",v) if worker.respond_to?(k)
          end
          worker.from = @from 
          worker.to = @to
          worker.data = @data
          @worker_instance = worker
        end
      
      when "MediaConverterRobot"
        if worker_instance.station
          @worker_instance = worker_instance
        else
          @url = worker_instance.url
          @to = worker_instance.to
          @audio_quality = worker_instance.audio_quality
          @video_quality = worker_instance.video_quality
          resp = CF::MediaConverterRobot.post("/lines/#{CF.account_name}/#{self.line_title.downcase}/stations/#{self.index}/workers.json", :worker => {:type => "MediaConverterRobot", :url => [@url], :to => @to, :audio_quality => @audio_quality, :video_quality => @video_quality})
          worker = CF::MediaConverterRobot.new({})
          resp.to_hash.each_pair do |k,v|
            worker.send("#{k}=",v) if worker.respond_to?(k)
          end
          worker.url = @url
          worker.to = @to
          worker.audio_quality = @audio_quality
          worker.video_quality = @video_quality
          @worker_instance = worker
        end
      
      when "ContentScrapingRobot"
        if worker_instance.station
          @worker_instance = worker_instance
        else
          @document = worker_instance.document
          @query = worker_instance.query
          resp = CF::ContentScrapingRobot.post("/lines/#{CF.account_name}/#{self.line_title.downcase}/stations/#{self.index}/workers.json", :worker => {:type => "ContentScrapingRobot", :document => @document, :query => @query})
          worker = CF::ContentScrapingRobot.new({})
          resp.to_hash.each_pair do |k,v|
            worker.send("#{k}=",v) if worker.respond_to?(k)
          end
          worker.document = @document
          worker.query = @query
          @worker_instance = worker
        end
        
      else
        if worker_instance.station
          @worker_instance = worker_instance 
        else
          @number = worker_instance.number.nil? ? 1 : worker_instance.number
          @reward = worker_instance.reward.nil? ? 0 : worker_instance.reward
          resp = worker_instance.class.post("/lines/#{CF.account_name}/#{self.line_title.downcase}/stations/#{self.index}/workers.json", :body => {:worker => {:number => @number, :reward => @reward, :type => type}})
          worker = worker_instance.class.new({})
          resp.to_hash.each_pair do |k,v|
            worker.send("#{k}=",v) if worker.respond_to?(k)
          end
          @worker_instance = worker
        end
      end
    end

    # ==Creates new form for station object
    # ===Usage of Instruction method for "station" object
    #   line = CF::Line.new("line name", "Survey")
    #   station = CF::Station.new({:type => "work"})
    #   line.stations station
    #   standard_form = CF::Form.new({:title => "title", :description => "description"})
    #   line.stations.first.form form
    def form form_instance = nil
      if form_instance
        @form_instance = form_instance
      else
        @form_instance
      end
    end
    
    def form=(form_instance) # :nodoc:
      if form_instance.class == Hash
        form_type = form_instance['_type']
        @form = eval(form_type.camelize).new({})
        form_instance.to_hash.each_pair do |k,v|
          @form.send("#{k}=",v) if @form.respond_to?(k)
        end
      else
        @form = form_instance
      end
      
      if @form.station
        @form_instance = @form
      else
        @title = @form.title
        @instruction = @form.instruction
        type = @form.class.to_s.split("::").last
        form = @form.class.new({})
        if type == "CustomTaskForm"
          @html = @form.raw_html
          @css = @form.raw_css
          @javascript = @form.raw_javascript
          @resp = CF::CustomTaskForm.post("/lines/#{CF.account_name}/#{self.line_title.downcase}/stations/#{self.index}/form.json", :form => {:title => @title, :instruction => @instruction, :_type => "CustomTaskForm", :raw_html => @html, :raw_css => @css, :raw_javascript => @javascript})
        else
          @resp = CF::TaskForm.post("/lines/#{CF.account_name}/#{self.line_title.downcase}/stations/#{self.index}/form.json", :form => {:title => @title, :instruction => @instruction, :_type => type}) 
        end
        @resp.to_hash.each_pair do |k,v|
          form.send("#{k}=",v) if form.respond_to?(k)
        end
        form.station = self
        @form_instance = form
      end
    end

    # ==Usage of line.input_formats(input_format)
    #   line = CF::Line.new("line name", "Survey")
    #   station = CF::Station.new({:type => "work"})
    #   line.stations station
    #   input_format = CF::InputFormat.new({:line => l, :label => "Website", :field_type => "text_data", :value => "www.google.com", :required => true, :validation_format => "url"})
    #   line.stations.first.input_formats input_format
    # * returns
    # line.stationss.first.input_formats as an array of input_formats
    def input_formats input_formats_value = nil
      if input_formats_value
        name = input_formats_value.name
        required = input_formats_value.required
        valid_type = input_formats_value.valid_type
        resp = CF::InputFormat.post("/lines/#{CF.account_name}/#{self.line_title.downcase}/input_formats.json", :input_format => {:name => name, :required => required, :valid_type => valid_type})
        input_format = CF::InputFormat.new()
        resp.input_format.to_hash.each_pair do |k,v|
          input_format.send("#{k}=",v) if input_format.respond_to?(k)
        end
        @input_formats << input_format
      else
        @input_formats.first
      end
    end
    def input_formats=(input_formats_value) # :nodoc:
      @input_formats << input_formats_value
    end
    # ==Updates Standard Instruction of a station
    # ===Usage example
    #   line = CF::Line.create("Digitize Card","Digitization") do |l|
    #     CF::Station.create({:line => l, :type => "work") do |s|
    #       CF::HumanWorker.new({:station => s, :number => 1, :reward => 20)
    #     end
    #   end
    #   line.stations[0].update_form({:title => "Enter phone number from a business card image", :description => "Call"})
    def update_form(options={})
      @title       = options[:title]
      @description = options[:description]
      self.class.put("/stations/#{self.id}/form.json", :form => {:title => @title, :description => @description, :type => "Form"})
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
      resp = self.class.get("/lines/#{CF.account_name}/#{self.line_title.downcase}/stations/#{self.index}.json")
      return resp
    end

    # ==Returns information of form
    # ===Usage example
    #   line = CF::Line.create("Digitize Card","Digitization") do |l|
    #     CF::InputFormat.new({:line => l, :label => "Company", :field_type => "text_data", :value => "Google", :required => true, :validation_format => "general"})
    #     CF::InputFormat.new({:line => l, :label => "Website", :field_type => "text_data", :value => "www.google.com", :required => true, :validation_format => "url"})
    #     CF::Station.create({:line => l, :type => "work") do |s|
    #       CF::HumanWorker.new({:station => s, :number => 1, :reward => 20)
    #       CF::Form.create({:station => s, :title => "Enter text from a business card image", :description => "Describe"}) do |i|
    #         CF::FormField.new({:form => i, :label => "First Name", :field_type => "SA", :required => "true"})
    #         CF::FormField.new({:form => i, :label => "Middle Name", :field_type => "SA"})
    #         CF::FormField.new({:form => i, :label => "Last Name", :field_type => "SA", :required => "true"})
    #       end
    #     end
    #   end
    #
    #   @got_form = line.stations[0].get_form
    def get_form
      self.class.get("/lines/#{CF.account_name}/#{self.line_title.downcase}/stations/#{self.index}/form.json")
    end

    # ==Returns all the stations associated with a particular line
    # ===Usage example for station.all method is
    #   line = CF::Line.create("Digitize Card","Digitization") do |l|
    #     CF::InputFormat.new({:line => l, :label => "Company", :field_type => "text_data", :value => "Google", :required => true, :validation_format => "general"})
    #     CF::InputFormat.new({:line => l, :label => "Website", :field_type => "text_data", :value => "www.google.com", :required => true, :validation_format => "url"})
    #     CF::Station.create({:line => l, :type => "work") do |s|
    #       CF::HumanWorker.new({:station => s, :number => 1, :reward => 20)
    #       CF::Form.create({:station => s, :title => "Enter text from a business card image", :description => "Describe"}) do |i|
    #         CF::FormField.new({:form => i, :label => "First Name", :field_type => "SA", :required => "true"})
    #         CF::FormField.new({:form => i, :label => "Middle Name", :field_type => "SA"})
    #         CF::FormField.new({:form => i, :label => "Last Name", :field_type => "SA", :required => "true"})
    #       end
    #     end
    #   end
    #
    #   CF::Station.all(line)
    # returns all stations
    def self.all(line)
      get("/lines/#{CF.account_name}/#{line.title.downcase}/stations.json")
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
      self.class.delete("/lines/#{CF.account_name}/#{self.line_title.downcase}/stations/#{self.index}.json")
    end
  end
end