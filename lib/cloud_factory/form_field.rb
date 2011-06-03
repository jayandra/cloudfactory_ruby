module CloudFactory
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
    #   line = CloudFactory::Line.create("Digitize", "Survey") do |l|   
    #     CloudFactory::Station.create({:line => l, :type => "work"}) do |s|
    #       CloudFactory::StandardInstruction.create({:station => s, :title => "Enter text from a business card image", :description => "Describe"}) do |i|
    #         CloudFactory::FormField.new({:instruction => i, :label => "First Name", :field_type => "SA", :required => "true"})
    #       end
    #     end
    #   end
    def initialize(options={})
      @instruction  = options[:instruction]
      @label        = options[:label]
      @field_type   = options[:field_type]
      @required     = options[:required]
      if !@instruction.nil?
        resp = self.class.post("/stations/#{@instruction.station.id}/instruction/form_fields.json", :form_field => 
        {:label => @label, :field_type => @field_type, :required => @required})
        @id = resp.id
        @instruction.station.instruction.form_fields = self
      end
    end
  end
end