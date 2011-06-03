module CloudFactory
  class Form
    include Client
    
    # title of the standard_instruction
    attr_accessor :title
    
    # description about the instruction
    attr_accessor :description
    
    # form_fields for the Form
    attr_accessor :form_fields
    
    # station attributes required to store station information
    attr_accessor :station
    
    # ID of Standard Instruction
    attr_accessor :id

    # ==Initializes a new Form
    # ==Usage of standard_instruction.new
    #   attrs = {:title => "Enter text from a business card image",
    #       :description => "Describe"}
    #
    #   instruction = Form.new(attrs)
    def initialize(options={})
      @form_fields =[]
      @station     = options[:station]
      @title       = options[:title]
      @description = options[:description]
      if !@station.nil?
        resp = self.class.post("/stations/#{station.id}/instruction.json", :instruction => {:title => @title, :description => @description, :_type => "Form"})
        @id = resp.id
        @station.instruction = self
      end
    end
    
    # ==Initializes a new Form within block using Variable
    # ==Usage of "standard_instruction.create(hash) do |block|"
    # ===Creating Form using block variable
    #   line = CloudFactory::Line.create("Digitize Card","Digitization") do |l|
    #     CloudFactory::InputHeader.new({:line => l, :label => "Company", :field_type => "text_data", :value => "Google", :required => true, :validation_format => "general"})
    #     CloudFactory::InputHeader.new({:line => l, :label => "Website", :field_type => "text_data", :value => "www.google.com", :required => true, :validation_format => "url"})
    #     CloudFactory::Station.create({:line => l, :type => "work") do |s|
    #       CloudFactory::HumanWorker.new({:station => s, :number => 1, :reward => 20)
    #       CloudFactory::Form.create(:station => s, :title => "Enter text from a business card image", :description => "Describe"}) do |i|
    #         CloudFactory::FormField.new({:instruction => i, :label => "First Name", :field_type => "SA", :required => "true"})
    #         CloudFactory::FormField.new({:instruction => i, :label => "Middle Name", :field_type => "SA"})
    #         CloudFactory::FormField.new({:instruction => i, :label => "Last Name", :field_type => "SA", :required => "true"})            
    #       end
    #     end
    #   end
    #
    # ===OR without block variable
    #   line = CloudFactory::Line.create("Digitize Card","Digitization") do 
    #     CloudFactory::InputHeader.new({:line => self, :label => "Company", :field_type => "text_data", :value => "Google", :required => true, :validation_format => "general"})
    #     CloudFactory::InputHeader.new({:line => self, :label => "Website", :field_type => "text_data", :value => "www.google.com", :required => true, :validation_format => "url"})
    #     CloudFactory::Station.create({:line => self, :type => "work") do
    #       CloudFactory::HumanWorker.new({:station => self, :number => 1, :reward => 20)
    #       CloudFactory::Form.create(:station => self, :title => "Enter text from a business card image", :description => "Describe"}) do
    #         CloudFactory::FormField.new({:instruction => self, :label => "First Name", :field_type => "SA", :required => "true"})
    #         CloudFactory::FormField.new({:instruction => self, :label => "Middle Name", :field_type => "SA"})
    #         CloudFactory::FormField.new({:instruction => self, :label => "Last Name", :field_type => "SA", :required => "true"})            
    #       end
    #     end
    #   end
    #
    def self.create(options, &block)
      instruction = Form.new(options)
      if block.arity >= 1
        block.call(instruction)
      else
        instruction.instance_eval &block
      end
      instruction
    end
    
    # ==appending different form_fields 
    # ===Syntax for FormField method is form_fields << form_field_values
    # ==Usage of form_fields method
    #   line = CloudFactory::Line.create("Digitize Card","Digitization") do |l|
    #     CloudFactory::InputHeader.new({:line => l, :label => "Company", :field_type => "text_data", :value => "Google", :required => true, :validation_format => "general"})
    #     CloudFactory::InputHeader.new({:line => l, :label => "Website", :field_type => "text_data", :value => "www.google.com", :required => true, :validation_format => "url"})
    #     CloudFactory::Station.create({:line => l, :type => "work") do |s|
    #       CloudFactory::HumanWorker.new({:station => s, :number => 1, :reward => 20)
    #       CloudFactory::Form.create(:station => s, :title => "Enter text from a business card image", :description => "Describe"}) do |i|
    #         CloudFactory::FormField.new({:instruction => i, :label => "First Name", :field_type => "SA", :required => "true"})
    #         CloudFactory::FormField.new({:instruction => i, :label => "Middle Name", :field_type => "SA"})
    #         CloudFactory::FormField.new({:instruction => i, :label => "Last Name", :field_type => "SA", :required => "true"})            
    #       end
    #     end
    #   end
    #
    def form_fields form_fields = nil
      if form_fields
        label = form_fields.label
        field_type = form_fields.field_type
        required = form_fields.required
        resp = CloudFactory::FormField.post("/stations/#{self.station.id}/instruction/form_fields.json", :form_field => 
          {:label => label, :field_type => field_type, :required => required})
        form_field = CloudFactory::FormField.new({})
        resp.to_hash.each_pair do |k,v|
          form_field.send("#{k}=",v) if form_field.respond_to?(k)
        end
        @form_fields << form_field
      else
        @form_fields
      end
    end
    def form_fields=(form_fields) # :nodoc:
      @form_fields << form_fields
    end
    # ==Deletes Standard Instruction of a station
    # ==Usage example
    #   line = CloudFactory::Line.create("Digitize Card","Digitization") do |l|
    #     CloudFactory::InputHeader.new({:line => l, :label => "Company", :field_type => "text_data", :value => "Google", :required => true, :validation_format => "general"})
    #     CloudFactory::InputHeader.new({:line => l, :label => "Website", :field_type => "text_data", :value => "www.google.com", :required => true, :validation_format => "url"})
    #     CloudFactory::Station.create({:line => l, :type => "work") do |s|
    #       CloudFactory::HumanWorker.new({:station => s, :number => 1, :reward => 20)
    #       CloudFactory::Form.create(:station => s, :title => "Enter text from a business card image", :description => "Describe"}) do |i|
    #         CloudFactory::FormField.new({:instruction => i, :label => "First Name", :field_type => "SA", :required => "true"})
    #         CloudFactory::FormField.new({:instruction => i, :label => "Middle Name", :field_type => "SA"})
    #         CloudFactory::FormField.new({:instruction => i, :label => "Last Name", :field_type => "SA", :required => "true"})            
    #       end
    #     end
    #   end
    #   station = line.stations[0]
    #
    #   CloudFactory::Form.delete_instruction(station)
    # deletes standard_instruction of a station
    def self.delete_instruction(station)
      delete("/stations/#{station.id}/instruction.json")
    end
  end
end