module CF
  class TaskForm
    require 'httparty'
    include Client
    
    # title of the form
    attr_accessor :title
    
    # instruction of the form
    attr_accessor :instruction
    
    # form_fields of the Form
    attr_accessor :form_fields
    
    # station attributes required to store station information
    attr_accessor :station
    
    # Contains Error message if any
    attr_accessor :errors
    
    # ==Initializes a new Form
    # ===Usage Example:
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
        resp = self.class.post("/lines/#{CF.account_name}/#{@station.line['title'].downcase}/stations/#{@station.index}/form.json", :form => {:title => @title, :instruction => @instruction, :_type => "TaskForm"})
        resp.to_hash.each_pair do |k,v|
          self.send("#{k}=",v) if self.respond_to?(k)
        end
        if resp.code != 200
          self.errors = resp.error.message
        end
        @station.form = self
      end
    end
    
    # ==Initializes a new Form within block using Variable
    # ===Usage Example:
    #   line = CF::Line.create("Digitize Card","Digitization") do |l|
    #     CF::InputHeader.new({:line => l, :label => "Company", :required => true, :valid_type => "general"})
    #     CF::InputHeader.new({:line => l, :label => "Website", :required => true, :valid_type => "url"})
    #     CF::Station.create({:line => l, :type => "work") do |s|
    #       CF::HumanWorker.new({:station => s, :number => 1, :reward => 20)
    #       CF::Form.create(:station => s, :title => "Enter text from a business card image", :instruction => "Describe"}) 
    #     end
    #   end
    def self.create(options, &block)
      form = TaskForm.new(options)
      if block.arity >= 1
        block.call(form)
      else
        form.instance_eval &block
      end
      form
    end
    
    # ==Adding different form_fields 
    # ===Syntax for FormField method is form_fields << form_field_values
    # ==Usage of form_fields method
    #   line = CF::Line.create("Digitize Card","Digitization") do |l|
    #     CF::InputHeader.new({:line => l, :label => "Company", :required => true, :valid_type => "general"})
    #     CF::InputHeader.new({:line => l, :label => "Website", :required => true, :valid_type => "url"})
    #     CF::Station.create({:line => l, :type => "work") do |s|
    #       CF::HumanWorker.new({:station => s, :number => 1, :reward => 20)
    #       CF::Form.create(:station => s, :title => "Enter text from a business card image", :instruction => "Describe"}) do |i|
    #         CF::FormField.new({:instruction => i, :label => "First Name", :field_type => "SA", :required => "true"})
    #         CF::FormField.new({:instruction => i, :label => "Middle Name", :field_type => "SA"})
    #         CF::FormField.new({:instruction => i, :label => "Last Name", :field_type => "SA", :required => "true"})            
    #       end
    #     end
    #   end
    def form_fields form_fields = nil
      if form_fields
        form_field_params = form_fields.form_field_params
        party_param = 
        {
          :body => 
          {
            :api_key => CF.api_key,
            :form_field => form_field_params
          }
        }
        resp =  HTTParty.post("#{CF.api_url}#{CF.api_version}/lines/#{CF.account_name}/#{self.station.line_title.downcase}/stations/#{self.station.index}/form_fields.json",party_param)
        form_field = CF::FormField.new({})
        resp.parsed_response.to_hash.each_pair do |k,v|
          form_field.send("#{k}=",v) if form_field.respond_to?(k)
        end
        if resp.code != 200
          form_field.errors = resp.parsed_response['error']['message']
        end
        form_field.form_field_params = form_field_params
        @form_fields << form_field
      else
        @form_fields
      end
    end
    
    def form_fields=(form_fields) # :nodoc:
      @form_fields << form_fields
    end
    
    def to_s
      "{:title => #{self.title}, :instruction => #{self.instruction}, :form_fields => #{self.form_fields}, :errors => #{self.errors}}"
    end
  end
end