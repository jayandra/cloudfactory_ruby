module CF
  class Station
    require 'httparty'
    include Client

    # type of the station, e.g. station = Station.new({:type => "Work"})
    attr_accessor :type

    # Title of line with which station is associated with
    attr_accessor :line_title

    # Index number of station
    attr_accessor :index
    
    # Line attribute of the station with which station is associated
    attr_accessor :line
    
    # Manual input format settings for the station
    attr_accessor :station_input_formats
    
    # Jury worker settings for the Tournament Station
    attr_accessor :jury_worker
    
    # Auto Judge settings for the Tournament Station
    attr_accessor :auto_judge
    
    # Contains Error Message if any
    attr_accessor :errors, :batch_size

    # ==Initializes a new station
    # ===Usage Example:
    #   line = CF::Line.new("Digitize", "Survey")
    #   station = CF::Station.new({:type => "Work"})
    #   line.stations station
    def initialize(options={})
      @input_formats =[]
      @line_title = options[:line].nil? ? nil : options[:line].title
      @type = options[:type].nil? ? nil : options[:type].camelize
      @jury_worker = options[:jury_worker]
      @auto_judge = options[:auto_judge]
      @station_input_formats = options[:input_formats]
      @line_instance = options[:line]
      @batch_size = options[:batch_size]
      if @batch_size.nil?
        request_general = 
        {
          :body => 
          {
            :api_key => CF.api_key,
            :station => {:type => @type, :input_formats => @station_input_formats}
          }
        }
        request_tournament = 
        {
          :body => 
          {
            :api_key => CF.api_key,
            :station => {:type => @type, :jury_worker => @jury_worker, :auto_judge => @auto_judge, :input_formats => @station_input_formats}
          }
        }
      else
        request_general = 
        {
          :body => 
          {
            :api_key => CF.api_key,
            :station => {:type => @type, :input_formats => @station_input_formats, :batch_size => @batch_size}
          }
        }
        request_tournament = 
        {
          :body => 
          {
            :api_key => CF.api_key,
            :station => {:type => @type, :jury_worker => @jury_worker, :auto_judge => @auto_judge, :input_formats => @station_input_formats, :batch_size => @batch_size}
          }
        }
      end
      if @line_title
        if @type == "Improve"
          line = options[:line]
          if line.stations.size < 1
            raise ImproveStationNotAllowed.new("You cannot add Improve Station as a first station of a line")
          else
            resp = HTTParty.post("#{CF.api_url}#{CF.api_version}/lines/#{CF.account_name}/#{@line_instance.title.downcase}/stations.json",request_general)
          end
        elsif @type == "Tournament"
          resp = HTTParty.post("#{CF.api_url}#{CF.api_version}/lines/#{CF.account_name}/#{@line_instance.title.downcase}/stations.json",request_tournament)
        else
          resp = HTTParty.post("#{CF.api_url}#{CF.api_version}/lines/#{CF.account_name}/#{@line_instance.title.downcase}/stations.json",request_general)
        end
        resp.to_hash.each_pair do |k,v|
          self.send("#{k}=",v) if self.respond_to?(k)
        end
        @line_instance.stations = self
        if resp.response.code != "200"
          self.errors = resp.parsed_response['error']['message']
        end
      end
    end

    # ==Creation of a new station
    # ===Usage Example
    #   line = CF::Line.create("Digitize Card","Digitization") do |l|
    #     CF::InputFormat.new({:line => l, :label => "Company", :required => "true", :valid_type => "general"})
    #     CF::InputFormat.new({:line => l, :label => "Website", :required => "true", :valid_type => "url"})
    #     CF::Station.create({:line => l, :type => "work") do |s|
    #       CF::HumanWorker.new({:station => s, :number => 1, :reward => 20)
    #       CF::Form.create({:station => s, :title => "Enter text from a business card image", :instruction => "Describe"}) do |i|
    #         CF::FormField.new({:form => i, :label => "First Name", :field_type => "SA", :required => "true"})
    #         CF::FormField.new({:form => i, :label => "Middle Name", :field_type => "SA"})
    #         CF::FormField.new({:form => i, :label => "Last Name", :field_type => "SA", :required => "true"})
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

    # ==Creates new Worker for station object
    # ===Usage Example:
    #   line = CF::Line.new("line name", "Survey")
    #   station = CF::Station.new({:type => "work"})
    #   line.stations station
    #   human_worker = CF::HumanWorker.new({:number => 1, :reward => 20})
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
      if worker_type == "HumanWorker"
        if worker_instance.station
          @worker_instance = worker_instance
        else
          number = worker_instance.number
          reward = worker_instance.reward
          badge = worker_instance.badge
          stat_badge = worker_instance.stat_badge
          if badge.nil? && stat_badge.nil?
            request = 
            {
              :body => 
              {
                :api_key => CF.api_key,
                :worker => {:number => number, :reward => reward, :type => "HumanWorker"}
              }
            }
          else
            request = 
            {
              :body => 
              {
                :api_key => CF.api_key,
                :worker => {:number => number, :reward => reward, :type => "HumanWorker"},
                :skill_badge => badge,
                :stat_badge => stat_badge
              }
            }
          end
          resp = HTTParty.post("#{CF.api_url}#{CF.api_version}/lines/#{CF.account_name}/#{self.line_title.downcase}/stations/#{self.index}/workers.json",request)
          worker = CF::HumanWorker.new({})
          worker.id =  resp.parsed_response['id']
          worker.number =  resp.parsed_response['number']
          worker.reward =  resp.parsed_response['reward']
          worker.stat_badge =  resp.parsed_response['stat_badge'] 
          worker.skill_badges << resp.parsed_response['skill_badges']
          if resp.code != 200
            worker.errors = resp.parsed_response['error']['message']
          end
          @worker_instance = worker
        end

      elsif worker_type == "RobotWorker"
        if worker_instance.station
          @worker_instance = worker_instance
        else
          @settings = worker_instance.settings
          @type = worker_instance.type
          request = @settings.merge(:type => @type)
          resp = CF::RobotWorker.post("/lines/#{CF.account_name}/#{self.line_title.downcase}/stations/#{self.index}/workers.json", :worker => request)
          worker = CF::RobotWorker.new({})
          worker.settings = @settings
          worker.type = @type
          worker.number = resp.number
          worker.reward = resp.reward
          if resp.code != 200
            worker.errors = resp.error.message
          end
          @worker_instance = worker
        end
      end
    end

    # ==Creates new form for station object
    # ===Usage Example:
    #   line = CF::Line.new("line name", "Survey")
    #   station = CF::Station.new({:type => "work"})
    #   line.stations station
    #   form = CF::Form.new({:title => "title", :instruction => "description"})
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
        if @resp.code != 200
          form.errors = @resp.error.message
        end
        form.station = self
        @form_instance = form
      end
    end

    # ==Returns a particular station of a line
    # ===Usage Example:
    #   line = CF::Line.create("Digitize", "Department_name")
    #   station = CF::Station.new({:type => "Work"})
    #   line.stations station
    #
    #   got_station = line.stations[0].get
    # returns the station object
    def get
      resp = self.class.get("/lines/#{CF.account_name}/#{self.line_title.downcase}/stations/#{self.index}.json")
      return resp
    end

    # ==Returns information of form
    # ===Usage example:
    #   @got_form = line.stations[0].get_form
    def get_form
      self.class.get("/lines/#{CF.account_name}/#{self.line_title.downcase}/stations/#{self.index}/form.json")
    end

    # ==Returns all the stations associated with a particular line
    # ===Usage Example:
    #   CF::Station.all(line)
    # returns all stations
    def self.all(line)
      get("/lines/#{CF.account_name}/#{line.title.downcase}/stations.json")
    end

    # ==Deletes a station
    # * We need to pass line object with which desired station associated with as an argument to delete a station
    # ===Usage example for delete method
    #   line = CF::Line.new("Digitize", "Department_name")
    #   station = CF::Station.new({:type => "Work"})
    #   line.stations station
    #
    #   line.stations.first.delete
    def delete
      self.class.delete("/lines/#{CF.account_name}/#{self.line_title.downcase}/stations/#{self.index}.json")
    end
    
    def to_s
      if self.type == "TournamentStation"
        "{:type => #{self.type}, :index => #{self.index}, :line_title => #{self.line_title}, :station_input_formats => #{self.station_input_formats}, :jury_worker => #{self.jury_worker}, auto_judge => #{self.auto_judge}, :errors => #{self.errors}}"
      else
        "{:type => #{self.type}, :index => #{self.index}, :line_title => #{self.line_title}, :station_input_formats => #{self.station_input_formats}, :errors => #{self.errors}}"
      end
    end
  end
end