module CF
  class CustomTaskForm
    include Client
    
    # Title of "custom_instruction" object, e.g. :title => "title_name of custom_instruction"
    attr_accessor :title
    
    # Description of "custom_instruction" object, e.g. :description => "description for title of custom_instruction"
    attr_accessor :instruction
    
    # raw_html is an attribute to store the custom html contents
    attr_accessor :raw_html
    
    # raw_css is an attribute to store the custom css contents 
    attr_accessor :raw_css
    
    # raw_javascript is an attribute to store the custom javascript contents
    attr_accessor :raw_javascript
    
    # station attribute is required for association with custom_from object
    attr_accessor :station
    
    # ==Initializes a new CustomForm
    # ===Usage custom_instruction.new(hash):
    #
    #     html = 'html_content'
    #     css = 'css_content'
    #     javascript = 'javascript_content'
    #
    #     instruction = CF::CustomTaskForm.new({:title => "Enter text from a business card image", :instruction => "Describe", :raw_html => html, :raw_css => css, :raw_javascript => javascript})
    def initialize(options={})
      @station     = options[:station]
      @title       = options[:title]
      @instruction = options[:instruction]
      @raw_html = options[:raw_html]
      @raw_css = options[:raw_css]
      @raw_javascript = options[:raw_javascript]
      if @station
        @resp = self.class.post("/lines/#{CF.account_name}/#{@station.line_title.downcase}/stations/#{@station.index}/form.json", :form => {:title => @title, :instruction => @instruction, :_type => "CustomTaskForm", :raw_html => @raw_html, :raw_css => @raw_css, :raw_javascript => @raw_javascript})
        custom_form = CF::CustomTaskForm.new({})
        @resp.to_hash.each_pair do |k,v|
          custom_form.send("#{k}=",v) if custom_form.respond_to?(k)
        end
        custom_form.station = @station
        @station.form = custom_form
      end
    end
  
    # ==Initializes a new CustomForm within block using Variable
    # ===Usage custom_instruction.create(hash):
    #
    #     html = 'html_content'
    #     css = 'css_content'
    #     javascript = 'javascript_content'
    #
    #     instruction = CF::CustomTaskForm.create({:title => "Enter text from a business card image", :instruction => "Describe", :raw_html => html, :raw_css => css, :raw_javascript => javascript})
    def self.create(form)
      instruction = CustomTaskForm.new(form)
    end
  end
end