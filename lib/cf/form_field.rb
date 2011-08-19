module CF
  class FormField
    require 'httparty'
    include Client

    # Label for "form" object, e.g. :label => "First Name"
    attr_accessor :label

    # field_type for "form" object, e.g. :field_type => "SA"
    attr_accessor :field_type

    # required boolean either true or false, e.g. :required => "true" & if false then you don't need to mention  
    attr_accessor :required

    # ID of form field
    attr_accessor :id

    # station id attribute required for API Calls
    attr_accessor :station_id
    
    # Parameters for form fields
    attr_accessor :form_field_params
    
    # Contains error message
    attr_accessor :errors

    # ==Initializes a new "form" object
    # ===Usage of form.new(hash):
    #   line = CF::Line.create("Digitize", "Survey") do |l|   
    #     CF::Station.create({:line => l, :type => "work"}) do |s|
    #       CF::TaskForm.create({:station => s, :title => "Enter text from a business card image", :instruction => "Describe"}) do |i|
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
        options.delete(:form)
        party_param = 
        {
          :body => 
          {
            :api_key => CF.api_key,
            :form_field => options
          }
        }
        resp =  HTTParty.post("#{CF.api_url}#{CF.api_version}/lines/#{CF.account_name}/#{@form.station.line['title'].downcase}/stations/#{@form.station.index}/form_fields.json",party_param)
        resp.parsed_response.each_pair do |k,v|
          self.send("#{k}=",v) if self.respond_to?(k)
        end
        if resp.code != 200
          self.errors = resp.parsed_response['error']['message']
        end
        self.form_field_params = options
        @form.station.form.form_fields = self
        return self
      else
        @form_field_params = options
      end
    end
    
    def to_s
      "{:id => => #{self.id}, :label => #{self.label}, :field_type => #{self.field_type}, :required => #{self.required}, :errors => #{self.errors}}"
    end
  end
end