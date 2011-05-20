module CloudFactory
  class Run
    include Client
    include ClientRequestResponse
    require 'json'
    # title of the "run" object
    attr_accessor :title

    # file attributes to upload
    attr_accessor :file
    
    # line attribute with which run is associated
    attr_accessor :line
    
    ## input_data for the Run
    #attr_accessor :input_data
    
    # ==Initializes a new Run
    # ==Usage Example:
    #     
    #   line = CloudFactory::Line.create("Digitize Card","Digitization") do |l|
    #     CloudFactory::InputHeader.new(l, attrs_1)
    #     CloudFactory::InputHeader.new(l, attrs_2)
    #     CloudFactory::Station.create(l, :type => "work") do |s|
    #       CloudFactory::HumanWorker.new(s, 2, 0.2)
    #       CloudFactory::StandardInstruction.create(s,{:title => "Enter text from a business card image", :description => "Describe"}) do |i|
    #         CloudFactory::FormField.new(s, {:label => "First Name", :field_type => "SA", :required => "true"})
    #         CloudFactory::FormField.new(s, {:label => "Middle Name", :field_type => "SA"})
    #         CloudFactory::FormField.new(s, {:label => "Last Name", :field_type => "SA", :required => "true"})            
    #       end
    #     end
    #   end
    # 
    #   run = CloudFactory::Run.new(line, "run name", File.expand_path("../../fixtures/input_data/test.csv", __FILE__))
    def initialize(line, title, file)
      @line = line
      @title = title
      @file = file
      @input_data =[]
      uri = "http://#{CloudFactory.api_url}/#{CloudFactory.api_version}/lines/#{line.id}/runs.json?api_key=#{CloudFactory.api_key}&email=#{CloudFactory.email}"
      resp = RestClient.post uri, {:title => @title, :file => File.new(@file, 'rb')}
      @id = Hashie::Mash.new(JSON.load(resp))._id
    end
    
    # ==Creates a new Run
    # ==Usage Example:
    #     
    #   line = CloudFactory::Line.create("Digitize Card","Digitization") do |l|
    #     CloudFactory::InputHeader.new(l, attrs_1)
    #     CloudFactory::InputHeader.new(l, attrs_2)
    #     CloudFactory::Station.create(l, :type => "work") do |s|
    #       CloudFactory::HumanWorker.new(s, 2, 0.2)
    #       CloudFactory::StandardInstruction.create(s,{:title => "Enter text from a business card image", :description => "Describe"}) do |i|
    #         CloudFactory::FormField.new(s, {:label => "First Name", :field_type => "SA", :required => "true"})
    #         CloudFactory::FormField.new(s, {:label => "Middle Name", :field_type => "SA"})
    #         CloudFactory::FormField.new(s, {:label => "Last Name", :field_type => "SA", :required => "true"})            
    #       end
    #     end
    #   end
    # 
    #   run = CloudFactory::Run.create(line, "run name", File.expand_path("../../fixtures/input_data/test.csv", __FILE__))
    def self.create(line, title, file)
      Run.new(line, title, file)
    end
    
    #Line.fire_run(@input_data, )
    #  POST http://cf.com/api/v1/lines/:id/runs
    #	 file.csv
    #  InputHeader.new(:label => "file")
  	#  InputHeader.new(:label => "duration")
    # 
    #  FormField.new(:lable => "duration", :value => 300)
    # 
    #  file, duration
    #www., 100
    
    ## ==Usage of input_headers.input_data << input_data_value
    #     #   attrs = {:label => "image_url",
    #     #     :field_type => "text_data",
    #     #     :value => "http://s3.amazon.com/bizcardarmy/medium/1.jpg",
    #     #     :required => true,
    #     #     :validation_format => "url"
    #     #   }
    #     #
    #     #   line = Line.new("line name") do |l|
    #     #     input_headers = CloudFactory::InputHeader.new(line, "attrs")
    #     #     l.input_headers = [input_headers]
    #     #     l.input_headers.input_data << input_data_value
    #     #   end
    #     # 
    #     # returns 
    #     #     line.input_headers.input_data
    #     def input_data input_data = nil
    #       if input_data
    #         input_data.each do |i|
    #           @input_data << i
    #         end
    #       else
    #         @input_data
    #       end
    #end
    
    
    def get
      self.class.get("/lines/#{@line.id}/runs/#{@id}.json")
    end
  end
end