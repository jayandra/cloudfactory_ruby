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
    
    # station id attribute required for API Calls
    attr_accessor :station_id
    
    # ==Initializes a new "form_field" object
    # ==Usage of form_field.new(hash):
    #   line = CloudFactory::Line.create("Digitize", "Survey") do |l|   
    #     CloudFactory::Station.create(l, :type => "work") do |s|
    #       CloudFactory::StandardInstruction.create(s,{:title => "Enter text from a business card image", :description => "Describe"}) do |i|
    #         CloudFactory::FormField.new(s, {:label => "First Name", :field_type => "SA", :required => "true"})
    #       end
    #     end
    #   end
    def initialize(instruction, options={})
      @station_id = instruction.station.id
      @label      = options[:label]
      @field_type = options[:field_type]
      @required   = options[:required]
      resp = self.class.post("/stations/#{@station_id}/instruction/form_fields.json", :body => {:form_field => 
        {:label => @label, :field_type => @field_type, :required => @required}})
      @id = resp._id
      instruction.station.instruction.form_fields = self
    end
  end
end