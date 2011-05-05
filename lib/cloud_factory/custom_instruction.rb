module CloudFactory
  class CustomInstruction
    # :title
    # :description  
    attr_accessor :title, :description, :html, :css, :javascript

    # ==<b>Initializes a new CustomInstruction</b><br><br>
    # ---
    # * <b>Usage Example:</b><br><br>
    #     attrs = {:title => "Enter text from a business card image",
    #         :description => "Describe"}
    #
    #     instruction = CustomInstruction.new(attrs)
    def initialize(options={})
      @title       = options[:title]
      @description = options[:description]
    end
  
    # ==<b>Initializes a new CustomInstruction within block using Variable</b><br><br>
    # ---
    # <br>
    # * <b>Usage Example:</b><br><br>
    #     attrs = {:title => "Enter text from a business card image",
    #         :description => "Describe"}
    #     
    #     html_content = '<div>.........</div>'
    #
    #     css_content = 'body {background:#fbfbfb;}
    #         #instructions{
    #           text-align:center;
    #         }.....'
    #
    #     javascript_content = '<script>.........</script>'
    #
    #     instruction = CustomInstruction.create(instruction) do |i|
    #       i.html = html_content 
    #       i.css = css_content
    #       i.javascript = javascript_content
    #     end
    #
    #   <br>OR without block variable
    #     instruction = CustomInstruction.create(instruction) do
    #       html html_content 
    #       css css_content
    #       javascript javascript_content
    #     end  
    #--
    def self.create(instruction, &block)
      instruction = CustomInstruction.new(instruction)
      if block.arity >= 1
        block.call(instruction)
      else
        instruction.instance_eval &block
      end
      instruction
    end

    # ==Usage of instruction.html<br><br>
    # ---
    # <br>
    #     html_content = '<div>.........</div>'
    #
    #     instruction.html = html_content
    #
    def html html = nil
      if html
        @html = html
      else
        @html
      end
    end

    # ==Usage of instruction.css<br><br>
    # ---
    # <br>
    #     css_content = 'body {background:#fbfbfb;}
    #         #instructions{
    #           text-align:center;
    #         }.....'
    #
    #     instruction.css = css_content
    def css css = nil
      if css
        @css = css
      else
        @css
      end
    end
    
    # ==Usage of instruction.javascript<br><br> 
    # ---   
    # <br>
    #     javascript_content = '<script>.........</script>'
    #
    #     instruction.html = javascript_content
    def javascript javascript = nil
      if javascript
        @javascript = javascript
      else
        @javascript
      end
    end

  end
end