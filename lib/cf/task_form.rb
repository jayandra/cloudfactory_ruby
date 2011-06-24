module CF
  class TaskForm
    include Client
    
    # title of the standard_instruction
    attr_accessor :title
    
    # instruction about the instruction
    attr_accessor :instruction
    
    # form_fields for the Form
    attr_accessor :form_fields
    
    # station attributes required to store station information
    attr_accessor :station
    
    # ID of Standard Instruction
    attr_accessor :id

    # ==Initializes a new Form
    # ==Usage of standard_instruction.new
    #   attrs = {:title => "Enter text from a business card image",
    #       :instruction => "Describe"}
    #
    #   instruction = CF::Form.new(attrs)
    def initialize(options={})
      @form_fields =[]
      @station     = options[:station]
      @title       = options[:title]
      @instruction = options[:instruction]
      if !@station.nil?
        resp = self.class.post("/stations/#{station.id}/form.json", :form => {:title => @title, :instruction => @instruction, :_type => "TaskForm"})
        @id = resp.id
        @station.form = self
      end
    end
    
    # ==Initializes a new Form within block using Variable
    # ==Usage of "standard_instruction.create(hash) do |block|"
    # ===Creating Form using block variable
    #   line = CF::Line.create("Digitize Card","Digitization") do |l|
    #     CF::InputHeader.new({:line => l, :label => "Company", :field_type => "text_data", :value => "Google", :required => true, :validation_format => "general"})
    #     CF::InputHeader.new({:line => l, :label => "Website", :field_type => "text_data", :value => "www.google.com", :required => true, :validation_format => "url"})
    #     CF::Station.create({:line => l, :type => "work") do |s|
    #       CF::HumanWorker.new({:station => s, :number => 1, :reward => 20)
    #       CF::Form.create(:station => s, :title => "Enter text from a business card image", :instruction => "Describe"}) do |i|
    #         CF::FormField.new({:instruction => i, :label => "First Name", :field_type => "SA", :required => "true"})
    #         CF::FormField.new({:instruction => i, :label => "Middle Name", :field_type => "SA"})
    #         CF::FormField.new({:instruction => i, :label => "Last Name", :field_type => "SA", :required => "true"})            
    #       end
    #     end
    #   end
    #
    # ===OR without block variable
    #   line = CF::Line.create("Digitize Card","Digitization") do 
    #     CF::InputHeader.new({:line => self, :label => "Company", :field_type => "text_data", :value => "Google", :required => true, :validation_format => "general"})
    #     CF::InputHeader.new({:line => self, :label => "Website", :field_type => "text_data", :value => "www.google.com", :required => true, :validation_format => "url"})
    #     CF::Station.create({:line => self, :type => "work") do
    #       CF::HumanWorker.new({:station => self, :number => 1, :reward => 20)
    #       CF::Form.create(:station => self, :title => "Enter text from a business card image", :instruction => "Describe"}) do
    #         CF::FormField.new({:instruction => self, :label => "First Name", :field_type => "SA", :required => "true"})
    #         CF::FormField.new({:instruction => self, :label => "Middle Name", :field_type => "SA"})
    #         CF::FormField.new({:instruction => self, :label => "Last Name", :field_type => "SA", :required => "true"})            
    #       end
    #     end
    #   end
    #
    def self.create(options, &block)
      form = TaskForm.new(options)
      if block.arity >= 1
        block.call(form)
      else
        form.instance_eval &block
      end
      form
    end
    
    # ==appending different form_fields 
    # ===Syntax for FormField method is form_fields << form_field_values
    # ==Usage of form_fields method
    #   line = CF::Line.create("Digitize Card","Digitization") do |l|
    #     CF::InputHeader.new({:line => l, :label => "Company", :field_type => "text_data", :value => "Google", :required => true, :validation_format => "general"})
    #     CF::InputHeader.new({:line => l, :label => "Website", :field_type => "text_data", :value => "www.google.com", :required => true, :validation_format => "url"})
    #     CF::Station.create({:line => l, :type => "work") do |s|
    #       CF::HumanWorker.new({:station => s, :number => 1, :reward => 20)
    #       CF::Form.create(:station => s, :title => "Enter text from a business card image", :instruction => "Describe"}) do |i|
    #         CF::FormField.new({:instruction => i, :label => "First Name", :field_type => "SA", :required => "true"})
    #         CF::FormField.new({:instruction => i, :label => "Middle Name", :field_type => "SA"})
    #         CF::FormField.new({:instruction => i, :label => "Last Name", :field_type => "SA", :required => "true"})            
    #       end
    #     end
    #   end
    #
    def form_fields form_fields = nil
      if form_fields
        label = form_fields.label
        field_type = form_fields.field_type
        required = form_fields.required
        resp = CF::FormField.post("/stations/#{self.station.id}/form/form_fields.json", :form_field => 
          {:label => label, :field_type => field_type, :required => required})
        form_field = CF::FormField.new({})
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
    #   line = CF::Line.create("Digitize Card","Digitization") do |l|
    #     CF::InputHeader.new({:line => l, :label => "Company", :field_type => "text_data", :value => "Google", :required => true, :validation_format => "general"})
    #     CF::InputHeader.new({:line => l, :label => "Website", :field_type => "text_data", :value => "www.google.com", :required => true, :validation_format => "url"})
    #     CF::Station.create({:line => l, :type => "work") do |s|
    #       CF::HumanWorker.new({:station => s, :number => 1, :reward => 20)
    #       CF::Form.create(:station => s, :title => "Enter text from a business card image", :instruction => "Describe"}) do |i|
    #         CF::FormField.new({:instruction => i, :label => "First Name", :field_type => "SA", :required => "true"})
    #         CF::FormField.new({:instruction => i, :label => "Middle Name", :field_type => "SA"})
    #         CF::FormField.new({:instruction => i, :label => "Last Name", :field_type => "SA", :required => "true"})            
    #       end
    #     end
    #   end
    #   station = line.stations[0]
    #
    #   CF::Form.delete_instruction(station)
    # deletes standard_instruction of a station
    def self.delete_instruction(station)
      delete("/stations/#{station.id}/form.json")
    end
  end
end