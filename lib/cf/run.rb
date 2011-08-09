module CF
  class Run
    require 'httparty'
    include Client

    # title of the "run" object
    attr_accessor :title

    # file attributes to upload
    attr_accessor :file, :input

    # line attribute with which run is associated
    attr_accessor :line

    attr_accessor :id, :errors

    # ==Initializes a new Run
    # ==Usage Example:
    #
    #   line = CF::Line.create("Digitize Card","Digitization") do |l|
    #     CF::InputHeader.new({:label => "Company", :field_type => "text_data", :value => "Google", :required => true, :validation_format => "general"})
    #     CF::InputHeader.new({:label => "Website", :field_type => "text_data", :value => "www.google.com", :required => true, :validation_format => "url"})
    #     CF::Station.create({:line => l, :type => "work") do |s|
    #       CF::HumanWorker.new({:station => s, :number => 1, :reward => 20)
    #       CF::StandardInstruction.create(:station => s, :title => "Enter text from a business card image", :description => "Describe"}) do |i|
    #         CF::FormField.new({:instruction => i, :label => "First Name", :field_type => "SA", :required => "true"})
    #         CF::FormField.new({:instruction => i, :label => "Middle Name", :field_type => "SA"})
    #         CF::FormField.new({:instruction => i, :label => "Last Name", :field_type => "SA", :required => "true"})
    #       end
    #     end
    #   end
    #
    #   run = CF::Run.new(line, "run name", File.expand_path("../../fixtures/input_data/test.csv", __FILE__))
    def initialize(line, title, input)
      if line.class == CF::Line
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
    # ==Usage Example:
    #
    #   line = CF::Line.create("Digitize Card","Digitization") do |l|
    #     CF::InputHeader.new({:line => l, :label => "Company", :field_type => "text_data", :value => "Google", :required => true, :validation_format => "general"})
    #     CF::InputHeader.new({:line => l, :label => "Website", :field_type => "text_data", :value => "www.google.com", :required => true, :validation_format => "url"})
    #     CF::Station.create({:line => l, :type => "work") do |s|
    #       CF::HumanWorker.new({:station => s, :number => 1, :reward => 20)
    #       CF::StandardInstruction.create(:station => s, :title => "Enter text from a business card image", :description => "Describe"}) do |i|
    #         CF::FormField.new({:instruction => i, :label => "First Name", :field_type => "SA", :required => "true"})
    #         CF::FormField.new({:instruction => i, :label => "Middle Name", :field_type => "SA"})
    #         CF::FormField.new({:instruction => i, :label => "Last Name", :field_type => "SA", :required => "true"})
    #       end
    #     end
    #   end
    #
    #   run = CF::Run.create(line, "run name", File.expand_path("../../fixtures/input_data/test.csv", __FILE__))
    def self.create(line, title, file)
      Run.new(line, title, file)
    end

    def get # :nodoc:
      self.class.get("/lines/#{@line.id}/runs/#{@id}.json")
    end

    def self.get_final_output(run_id)
      resp = get("/runs/#{run_id}/final_outputs.json")

      @final_output =[]
      resp.each do |r|
        result = FinalOutput.new()
        r.to_hash.each_pair do |k,v|
          result.send("#{k}=",v) if result.respond_to?(k)
        end
        @final_output << result
      end
      return @final_output
    end

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

    def self.final_output(title)
      resp = get("/runs/#{CF.account_name}/#{title.downcase}/output.json")
      return resp['output']
      # debugger
      # @final_output =[]
      # resp['output'].each do |r|
      #   result = FinalOutput.new()
      #   r.to_hash.each_pair do |k,v|
      #     result.send("#{k}=",v) if result.respond_to?(k)
      #   end
      #   # if result.final_output == nil
      #   #   result.final_output = resp.output
      #   # end
      #   @final_output << result
      # end
      # debugger
      # return @final_output
    end
    
    def self.output(options={})
      station_no = options[:station]
      title = options[:title]
      resp = get("/runs/#{CF.account_name}/#{title.downcase}/output/#{station_no}.json")
      return resp['output']
    end
    
    def output(options={})
      station_no = options[:station]
      resp = self.class.get("/runs/#{CF.account_name}/#{self.title.downcase}/output/#{station_no}.json")
      return resp['output'].first.to_hash
    end
    
    def self.find(title)
      resp = get("/runs/#{CF.account_name}/#{title.downcase}.json")
      if resp.code != 200
        resp.error = resp.error.message
        resp.merge!(:errors => "#{resp.error}")
        resp.delete(:error)
      end
      return resp
    end
  end
end