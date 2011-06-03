module CloudFactory
  class InputHeader
    include Client

    # label for the input_header, e.g. :label => "image_url"
    attr_accessor :label
    
    # field_type for the input_header, e.g. :field_type => "text_data"
    attr_accessor :field_type
    
    # value or source for the input_header, e.g. :value => "http://s3.amazon.com/bizcardarmy/medium/.."
    attr_accessor :value
    
    # required boolean either true or false , e.g. :required => "true" & if false then you don't need to mention
    attr_accessor :required
    
    # validation_format format of the source for the input_header, e.g. :validation_format => "url"
    attr_accessor :validation_format
    
    # ID of an input_header 
    attr_accessor :id
    
    # ID of Line with which input_header is associated
    attr_accessor :line_id
    
    # ==Initializes a new input_header
    # * Syntax for creating new input_header: <b>InputHeader.new(</b> Hash <b>)</b>
    # ===Usage Example:
    #   attrs = {:label => "image_url",
    #     :field_type => "text_data",
    #     :value => "http://s3.amazon.com/bizcardarmy/medium/1.jpg",
    #     :required => true,
    #     :validation_format => "url"} 
    #   line = CloudFactory::Line.create("Digitize", "Survey")   
    #   input_header = CloudFactory::InputHeader.new(line, attrs) 
    #
    def initialize(options={})
      @station            = options[:station]
      @label              = options[:label]
      @field_type         = options[:field_type]
      @value              = options[:value]
      @required           = options[:required]
      @validation_format  = options[:validation_format]
      if !@station.nil?
        resp = self.class.post("/lines/#{@station.line_id}/input_headers.json", :input_header => {:label => @label, :field_type => @field_type, :value => @value, :required => @required, :validation_format => @validation_format})
        @id = resp.id
        @line_id = @station.line_id
        @station.input_headers = self
      end
    end
    
    # ==Returns all the input headers of a specific line
    #   attrs_1 = {:label => "image_url",
    #     :field_type => "text_data",
    #     :value => "http://s3.amazon.com/bizcardarmy/medium/1.jpg", 
    #     :required => true, 
    #     :validation_format => "url"
    #   }
    #   attrs_2 = {:label => "text_url",
    #     :field_type => "text_data",
    #     :value => "http://s3.amazon.com/bizcardarmy/", 
    #     :required => true, 
    #     :validation_format => "url"
    #   }
    #   
    #   line = CloudFactory::Line.create("Digitize Card","4dc8ad6572f8be0600000001") do |l|
    #     input_header_1 = CloudFactory::InputHeader.new(l, attrs_1)
    #     input_header_2 = CloudFactory::InputHeader.new(l, attrs_2)
    #   end
    #   input_headers_of_line = CloudFactory::InputHeader.all(line)
    # returns an array of input headers associated with line
    def self.all(line)
      get("/lines/#{line.id}/input_headers.json")
    end
    
    # ==Returns a particular input header of a specific line
    # ===Usage example
    #   attrs_1 = {:label => "image_url_type",
    #        :field_type => "text_data",
    #        :value => "http://s3.amazon.com/bizcardarmy/medium/1.jpg", 
    #        :required => true, 
    #        :validation_format => "url"
    #   }
    #      
    #   line = CloudFactory::Line.create("Digitize","4dc8ad6572f8be0600000006") do |l|
    #     CloudFactory::InputHeader.new(l, attrs_1)
    #   end
    #   input_header = line.input_headers[0]
    #   got_input_header = input_header.get
    def get
      self.class.get("/lines/#{line_id}/input_headers/#{id}.json")
    end
    
    # ==Updates input header
    # ===Usage example
    #   attrs_1 = {:label => "image_url_type",
    #     :field_type => "text_data",
    #     :value => "http://s3.amazon.com/bizcardarmy/medium/1.jpg", 
    #     :required => true, 
    #     :validation_format => "url"
    #   }
    #   
    #   line = CloudFactory::Line.create("Digitize","4dc8ad6572f8be0600000006") do |l|
    #     CloudFactory::InputHeader.new(l, attrs_1)
    #   end
    #   input_header = line.input_headers[0]
    #   updated_input_header = input_header.update({:label => "jackpot", :field_type => "lottery"})
    def update(options={})
      @label              = options[:label]
      @field_type         = options[:field_type]
      @value              = options[:value]
      @required           = options[:required]
      @validation_format  = options[:validation_format]
      self.class.put("/lines/#{line_id}/input_headers/#{id}.json", :input_header => {:label => @label, :field_type => @field_type, :value => @value, :required => @required, :validation_format => @validation_format})
    end
    
    # ==Deletes an input header of a specific line
    # ===Usage example
    #   attrs = {:label => "image_url_type",
    #     :field_type => "text_data",
    #     :value => "http://s3.amazon.com/bizcardarmy/medium/1.jpg", 
    #     :required => true, 
    #     :validation_format => "url"
    #   }
    #   
    #   line = CloudFactory::Line.create("Digitize","4dc8ad6572f8be0600000006") do |l|
    #     CloudFactory::InputHeader.new(l, attrs)
    #   end
    #
    #   input_header = line.input_headers[0]
    #   input_header.delete
    # deletes input header
    def delete
      self.class.delete("/lines/#{line_id}/input_headers/#{id}.json")
    end
  end
end