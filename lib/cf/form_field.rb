module CF
  class FormField
    include Client

    # Label for "form_field" object, e.g. :label => "First Name"
    attr_accessor :label

    # field_type for "form_field" object, e.g. :field_type => "SA"
    attr_accessor :field_type

    # required boolean either true or false, e.g. :required => "true" & if false then you don't need to mention  
    attr_accessor :required

    # ID of form field
    attr_accessor :id

    # station id attribute required for API Calls
    attr_accessor :station_id

    # ==Initializes a new "form_field" object
    # ==Usage of form_field.new(hash):
    #   line = CF::Line.create("Digitize", "Survey") do |l|   
    #     CF::Station.create({:line => l, :type => "work"}) do |s|
    #       CF::StandardInstruction.create({:station => s, :title => "Enter text from a business card image", :description => "Describe"}) do |i|
    #         CF::FormField.new({:form => i, :label => "First Name", :field_type => "SA", :required => "true"})
    #       end
    #     end
    #   end
    def initialize(options={})
      @form  = options[:form]
      @label        = options[:label]
      @field_type   = options[:field_type]
      @required     = options[:required]
      if !@form.nil?
        resp = self.class.post("/lines/#{CF.account_name}/#{@form.station.line['title'].downcase}/stations/#{@form.station.index}/form_fields.json", :form_field => {:label => @label, :field_type => @field_type, :required => @required})
        resp.to_hash.each_pair do |k,v|
          self.send("#{k}=",v) if self.respond_to?(k)
        end
        @form.station.form.form_fields = self
      end
    end
  end
end