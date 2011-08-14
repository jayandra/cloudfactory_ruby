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
    
    # Contains Error message if any
    attr_accessor :errors
    
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
        resp = self.class.post("/lines/#{CF.account_name}/#{@station.line_title.downcase}/stations/#{@station.index}/form.json", :form => {:title => @title, :instruction => @instruction, :_type => "CustomTaskForm", :raw_html => @raw_html, :raw_css => @raw_css, :raw_javascript => @raw_javascript})
        resp.to_hash.each_pair do |k,v|
          self.send("#{k}=",v) if self.respond_to?(k)
        end
        if resp.code != 200
          self.errors = resp.error.message
        end
        @station.form = self
        return self
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
    
    def to_s
      "{:title => #{self.title}, :instruction => #{self.instruction}, :raw_html => #{self.raw_html}, :raw_css => #{self.raw_css}, :raw_javascript => #{self.raw_javascript}, :errors => #{self.errors}}"
    end
  end
end