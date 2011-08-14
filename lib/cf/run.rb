module CF
  class Run
    require 'httparty'
    include Client

    # Title of the "run" object
    attr_accessor :title

    # File attribute to upload for Production Run
    attr_accessor :file
    
    # Input to be passed for Production Run
    attr_accessor :input

    # Line attribute with which run is associated
    attr_accessor :line
    
    # Contains Error Message if any
    attr_accessor :errors

    # ==Initializes a new Run
    # ===Usage Example:
    #
    #   run = CF::Run.new("line_title", "run name", file_path)
    #
    # ==OR
    # You can pass line object instead of passing line title:
    #   run = CF::Run.new(line_object, "run name", file_path)
    def initialize(line, title, input)
      if line.class == CF::Line || Hashie::Mash
        @line = line
        @line_title = @line.title
      else
        @line_title = line
      end
      @title = title
      if File.exist?(input.to_s)
        @file = input
        @param_data = File.new(input, 'rb')
        @param_for_input = :file
        resp = self.class.post("/lines/#{CF.account_name}/#{@line_title.downcase}/runs.json", {:data => {:run => {:title => @title}}, @param_for_input => @param_data})
        if resp.code != 200
          self.errors = resp.error.message
        end
      else
        @input = input
        @param_data = input
        @param_for_input = :inputs
        options = 
        {
          :body => 
          {
            :api_key => CF.api_key,
            :data =>{:run => { :title => @title }, :inputs => @param_data}
          }
        }
        run =  HTTParty.post("#{CF.api_url}#{CF.api_version}/lines/#{CF.account_name}/#{@line_title.downcase}/runs.json",options)
        if run.code != 200
          self.errors = run.parsed_response['error']['message']
        end
      end
    end

    # ==Creates a new Run
    # ===Usage Example:
    #
    #   run = CF::Run.new("line_title", "run name", file_path)
    #
    # ==OR
    # You can pass line object instead passing line title:
    #   run = CF::Run.new(line_object, "run name", file_path)
    def self.create(line, title, file)
      Run.new(line, title, file)
    end

    # ==Returns Final Output of production Run
    # ===Usage Example:
    #   run_object.final_output
    def final_output
      resp = self.class.get("/runs/#{CF.account_name}/#{self.title.downcase}/output.json")
      @final_output =[]
      resp['output'].each do |r|
        result = FinalOutput.new()
        r.to_hash.each_pair do |k,v|
          result.send("#{k}=",v) if result.respond_to?(k)
        end
        if result.final_output == nil
          result.final_output = resp.output
        end
        @final_output << result
      end
      return @final_output
    end

    # ==Returns Final Output of production Run
    # ===Usage Example:
    #   CF::Run.final_output("run_title")
    def self.final_output(title)
      resp = get("/runs/#{CF.account_name}/#{title.downcase}/output.json")
      return resp['output']
    end
    
    # ==Returns Output of production Run for any specific Station and for given Run Title
    # ===Usage Example:
    #   CF::Run.output({:title => "run_title", :station => 2})
    # Will return output of second station
    def self.output(options={})
      station_no = options[:station]
      title = options[:title]
      resp = get("/runs/#{CF.account_name}/#{title.downcase}/output/#{station_no}.json")
      return resp['output']
    end
    
    # ==Returns Output of Run object for any specific Station
    # ===Usage Example:
    #   run_object.output(:station => 2)
    # Will return output of second station
    def output(options={})
      station_no = options[:station]
      resp = self.class.get("/runs/#{CF.account_name}/#{self.title.downcase}/output/#{station_no}.json")
      return resp['output'].first.to_hash
    end
    
    # ==Searches Run for the given "run_title"
    # ===Usage Example:
    #   CF::Run.find("run_title")
    def self.find(title)
      resp = get("/runs/#{CF.account_name}/#{title.downcase}.json")
      if resp.code != 200
        resp.error = resp.error.message
        resp.merge!(:errors => "#{resp.error}")
        resp.delete(:error)
      end
      return resp
    end
    
    def self.progress(run_title)
      get("/runs/#{CF.account_name}/#{run_title}/progress.json")
    end
    
    def progress
      self.class.get("/runs/#{CF.account_name}/#{self.title}/progress.json")
    end
    
    def self.progress_details(run_title)
      resp = get("/runs/#{CF.account_name}/#{run_title}/details.json")
      return resp['progress_details']
    end
    
    def progress_details
      resp = self.class.get("/runs/#{CF.account_name}/#{self.title}/details.json")
      return resp['progress_details']
    end
  end
end