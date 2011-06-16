module CF
  class CustomTaskForm
    include Client
    
    # Title of "custom_instruction" object, e.g. :title => "title_name of custom_instruction"
    attr_accessor :title
    
    # Description of "custom_instruction" object, e.g. :description => "description for title of custom_instruction"
    attr_accessor :description
    
    # raw_html is an attribute to store the custom html contents
    attr_accessor :raw_html
    
    # raw_css is an attribute to store the custom css contents 
    attr_accessor :raw_css
    
    # raw_javascript is an attribute to store the custom javascript contents
    attr_accessor :raw_javascript
    
    # station attribute is required for association with custom_from object
    attr_accessor :station

    # ==Initializes a new CustomForm
    # ==Usage custom_instruction.new(hash):
    #
    #     attrs = {:title => "Enter text from a business card image",
    #         :description => "Describe"}
    #
    #     instruction = CustomForm.new(attrs)
    def initialize(options={})
      @station     = options[:station]
      @title       = options[:title]
      @description = options[:description]
      @raw_html = options[:raw_html]
      @raw_css = options[:raw_css]
      @raw_javascript = options[:raw_javascript]
      if @station
        @resp = self.class.post("/stations/#{@station.id}/form.json", :form => {:title => @title, :description => @description, :_type => "CustomTaskForm", :raw_html => @raw_html, :raw_css => @raw_css, :raw_javascript => @raw_javascript})
        @id = @resp.id
        custom_form = CF::CustomTaskForm.new({})
        @resp.to_hash.each_pair do |k,v|
          custom_form.send("#{k}=",v) if custom_form.respond_to?(k)
        end
        custom_form.station = @station
        @station.instruction = custom_form
      end
    end
  
    # ==Initializes a new CustomForm within block using Variable
    # ==Usage of custom_instruction.create(instruction):
    # ===Creating CustomForm using block variable
    #     attrs = {:title => "Enter text from a business card image",
    #         :description => "Describe"}
    #     
    #     html_content = '<div>.........</div>'
    #
    #     css_content = 'body {background:#fbfbfb;}
    #          #instructions{
    #           text-align:center;
    #         }.....'
    #
    #     javascript_content = '<script>.........</script>'
    #
    #     instruction = CustomForm.create(instruction) do |i|
    #       i.html = html_content 
    #        i.css = css_content
    #        i.javascript = javascript_content
    #      end
    #
    # ===OR without block variable
    #     instruction = CustomForm.create(instruction) do
    #       html html_content 
    #       css css_content
    #       javascript javascript_content
    #     end
    def self.create(instruction)
      instruction = CustomTaskForm.new(instruction)
      # if block.arity >= 1
      #         block.call(instruction)
      #       else
      #         instruction.instance_eval &block
      #       end
      #       instruction
    end

    # ==Usage of instruction.html:
    #     html_content = '<div>.........</div>'
    #
    #     instruction.html = html_content
    #
    def html html_content = nil
      if html_content
        @html_content = html_content
      else
        @html_content
      end
    end
    def html=(html_content) # :nodoc:
      @html_content = html_content
    end

    # ==Usage of instruction.css:
    #     css_content = 'body {background:#fbfbfb;}
    #         #instructions{
    #           text-align:center;
    #         }.....'
    #
    #     instruction.css = css_content
    def css css_content = nil
      if css_content
        @css_content = css_content
      else
        @css_content
      end
    end
    def css=(css_content) # :nodoc:
      @css_content = css_content
    end
    # ==Usage of instruction.javascript:
    #     javascript_content = '<script>.........</script>'
    #
    #     instruction.html = javascript_content
    def javascript javascript_content = nil
      if javascript_content
        @javascript_content = javascript_content
      else
        @javascript_content
      end
    end
    def javascript=(javascript_content) # :nodoc:
      @javascript_content = javascript_content
    end
  end
end