module CF
  class InputFormat
    include Client

    # name for the input_format, e.g. :name => "image_url"
    attr_accessor :name
    
    # required boolean either true or false , e.g. :required => "true" & if false then you don't need to mention
    attr_accessor :required
    
    # valid_type format of the source for the input_format, e.g. :valid_type => "url"
    attr_accessor :valid_type
    
    # ID of an input_format 
    attr_accessor :id
    
    # ID of Line with which input_format is associated
    attr_accessor :line_title
    
    # ==Initializes a new input_format
    # * Syntax for creating new input_format: <b>InputFormat.new(</b> Hash <b>)</b>
    # ===Usage Example:
    #   line = CF::Line.create("Digitize", "Survey")
    #
    #   attrs = {:line => line,
    #     :name => "image_url",
    #     :required => true,
    #     :valid_type => "url"} 
    #   
    #   input_format = CF::InputFormat.new(attrs) 
    #   line.input_formats input_format
    def initialize(options={})
      @station            = options[:station]
      @line               = options[:line]
      @name              = options[:name]
      @required           = options[:required]
      @valid_type  = options[:valid_type]
      if !@station.nil? or !@line.nil?
        line_title = @station.nil? ? @line.title : @station.line_title
        resp = self.class.post("/lines/#{CF.account_name}/#{@line.title.downcase}/input_formats.json", :input_format => {:name => @name, :required => @required, :valid_type => @valid_type})
        @line_title = line_title
        if !@station.nil? && @station.except.nil? && @station.extra.nil?
          @station.input_formats = self
        else
          @line.input_formats = self
        end
      end
    end
    
    # ==Returns all the input headers of a specific line
    #   line = CF::Line.new("Digitize Card","Survey")
    #
    #   attrs_1 = {:line => line,
    #     :name => "image_url",
    #     :required => true, 
    #     :valid_type => "url"
    #   }
    #   attrs_2 = {:line => line,
    #     :name => "text_url", 
    #     :required => true, 
    #     :valid_type => "url"
    #   }
    #   
    #   input_format_1 = CF::InputFormat.new(attrs_1)
    #   line.input_formats input_format_1
    #   input_format_2 = CF::InputFormat.new(attrs_2)
    #   line.input_formats input_format_2
    # 
    #   input_formats_of_line = CF::InputFormat.all(line)
    # returns an array of input headers associated with line
    def self.all(line)
      get("/lines/#{CF.account_name}/#{line.title.downcase}/input_formats.json")
    end
    
    # ==Returns a particular input header of a specific line
    # ===Usage example
    #   line = CF::Line.new("Digitize Card","Survey")
    #   attrs = {:line => line,
    #     :name => "image_url_type",
    #     :required => true, 
    #     :valid_type => "url"
    #   }
    #      
    #   input_format = CF::InputFormat.new(attrs)
    #   line.input_formats input_format
    #   input_format = line.input_formats[0]
    #   
    #   got_input_format = input_format.get
    def get
      self.class.get("/lines/#{line_id}/input_formats/#{id}.json")
    end
    
    # ==Updates input header
    # ===Usage example
    #   line = CF::Line.new("Digitize Card","Survey")
    #   attrs = {:line => line,
    #     :name => "image_url_type", 
    #     :required => true, 
    #     :valid_type => "url"
    #   }
    #   
    #   input_format = CF::InputFormat.new(attrs)
    #   line.input_formats input_format
    #   input_format = line.input_formats[0]
    #
    #   updated_input_format = input_format.update({:name => "jackpot", :field_type => "lottery"})
    def update(options={})
      @name              = options[:name]
      @required           = options[:required]
      @valid_type  = options[:valid_type]
      self.class.put("/lines/#{line_id}/input_formats/#{id}.json", :input_format => {:name => @name, :required => @required, :valid_type => @valid_type})
    end
    
    #   line = CF::Line.new("Digitize Card","Survey")
    #   attrs = {:line => line,
    #     :name => "image_url_type", 
    #     :required => true, 
    #     :valid_type => "url"
    #   }
    #   
    #   input_format = CF::InputFormat.new(attrs)
    #   line.input_formats input_format
    #
    #   input_format = line.input_formats[0]
    #   input_format.delete
    # deletes input header
    def delete
      self.class.delete("/lines/#{line_id}/input_formats/#{id}.json")
    end
  end
end