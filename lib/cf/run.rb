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

    attr_accessor :id

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
      @line = line
      @title = title
      if File.exist?(input.to_s)
        @file = input
        @param_data = File.new(input, 'rb')
        @param_for_input = :file
        resp = self.class.post("/lines/#{CF.account_name}/#{@line.title.downcase}/runs.json", {:data => {:run => {:title => @title}}, @param_for_input => @param_data})
      else
        @input = input
        @param_data = input
        @param_for_input = :inputs
        options = {
          :body => {
           :api_key => CF.api_key,
           :data =>{:run => { :title => @title }, :inputs => @param_data
            }
          }
        }
        run =  HTTParty.post("#{CF.api_url}/#{CF.api_version}/lines/#{CF.account_name}/#{@line.title.downcase}/runs.json",options)
        # built_data = " -d \"run[title]=#{@title}\""
        #         @param_data.each do |d|
        #           d.each do |k, v|
        #             built_data += " -d \"inputs[][#{k}]=#{v}\""
        #           end
        #         end.join(" ")
        #         debugger
        #         uri = "-X POST #{:data => built_data} http://manish.lvh.me:3000/api/v1/lines/#{CF.account_name}/#{@line.title.downcase}/runs.json?api_key=f488a62d0307e79ec4f1e6131fa220be47e83d44"
        #         response = `curl #{uri}`
        #         debugger
        #         run_id = JSON.load(response)['run']['id']
        #         url = "http://manish.lvh.me:3000/api/v1/lines/#{CF.account_name}/#{@line.title.downcase}/runs/#{run_id}.json?api_key=f488a62d0307e79ec4f1e6131fa220be47e83d44"
        #         respo = `curl -I #{url}`
        #         if respo.scan(/\d{3}/).first == "200"
        #           parsed_response = JSON.load(response)
        #           if parsed_response.is_a?(Array)
        #             parsed_response.map{|item| Hashie::Mash.new(item)}
        #           else
        #             new_response = parsed_response.inject({ }) do |x, (k,v)|
        #                             x[k.sub(/\A_/, '')] = v
        #                             x
        #                           end
        #             resp = Hashie::Mash.new(new_response)
        #           end
        #         end
      end
      # @id = resp.id
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
      resp = self.class.get("/runs/#{CF.account_name}/#{self.title}/final_outputs.json")
      debugger
      @final_output =[]
      resp.each do |r|
        result = FinalOutput.new()
        r.to_hash.each_pair do |k,v|
          result.send("#{k}=",v) if result.respond_to?(k)
        end
        debugger
        @final_output << result
      end
      return @final_output
    end
    
    def output(options={})
      station_no = options[:station]
      line = self.line
      station = line.stations[station_no-1]
      resp = self.class.get("/runs/#{self.id}/output/#{station.id}.json")
      @final_output =[]
        result = FinalOutput.new()
        resp.to_hash.each_pair do |k,v|
          result.send("#{k}=",v) if result.respond_to?(k)
        end
        @final_output << result
      return @final_output
    end
    
  end
end