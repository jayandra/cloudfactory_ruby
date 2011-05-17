module CloudFactory
  class FormField
    include Client
    include ClientRequestResponse
    
    # Label for "form_field" object, e.g. :label => "First Name"
    attr_accessor :label
    
    # field_type for "form_field" object, e.g. :field_type => "SA"
    attr_accessor :field_type
    
    # required boolean either true or false, e.g. :required => "true" & if false then you don't need to mention  
    attr_accessor :required
    
    # ID of form field
    attr_accessor :id
    
    # station attribute required for API Calls
    attr_accessor :station
    
    # ==Initializes a new "form_field" object
    # ==Usage of form_field.new(hash):
    #     form_field = FormField.new(:label => "First Name", :field_type => "SA", :required => "true")
    def initialize(station, options={})
      @station    = station
      @label      = options[:label]
      @field_type = options[:field_type]
      @required   = options[:required]
      resp = self.class.post("/stations/#{station.id}/instruction/form_fields.json", :body => {:form_field => 
        {:label => @label, :field_type => @field_type, :required => @required}})
      @id = resp._id
    end
  end
end