module CloudFactory
  class Run
    include Client
    include ClientRequestResponse
    
    # title of the "run" object, e.g. run = Run.new("run_name")
    attr_accessor :title,:file, :line
    
    # input_data for the Run
    attr_accessor :input_data
    
    # ==Initializes a new Run
    # ==Usage Example:
    #     
    #   run = Run.new("RunName")
    def initialize(line, title, file)
      @line = line
      @title = title
      @file = file
      @input_data =[]
      resp = self.class.post("/lines/#{line.id}/runs.json", :body => {:run => {:title => @title, :file => @file}})
      @id = resp._id
    end
    
    # ==Initializes a new run
    # ==Usage of run.create("run_name") do |block|
    # ===creating Run within block using variable
    #   run = CloudFactory::Run.create("run name") do |r|
    #     r.input_data [{:name => "Bob Smith", :age => 23}, {:name => "John Doe", :age => 24}]
    #   end
    # 
    # ===OR creating without variable
    #   run = CloudFactory::Run.create("run name") do
    #     input_data [{:name => "Bob Smith", :age => 23}, {:name => "John Doe", :age => 24}]
    #   end
    def self.create(line, title, file)
      Run.new(line, name, file)
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
    
    # ==Usage of input_headers.input_data << input_data_value
    #   attrs = {:label => "image_url",
    #     :field_type => "text_data",
    #     :value => "http://s3.amazon.com/bizcardarmy/medium/1.jpg",
    #     :required => true,
    #     :validation_format => "url"
    #   }
    #
    #   line = Line.new("line name") do |l|
    #     input_headers = CloudFactory::InputHeader.new(line, "attrs")
    #     l.input_headers = [input_headers]
    #     l.input_headers.input_data << input_data_value
    #   end
    # 
    # returns 
    #     line.input_headers.input_data
    def input_data input_data = nil
      if input_data
        input_data.each do |i|
          @input_data << i
        end
      else
        @input_data
      end
    end
    
    
    def get
      self.class.get("/lines/#{@line.id}/runs/#{@id}.json")
    end
  end
end