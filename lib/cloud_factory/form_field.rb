module CloudFactory
  class FormField
    attr_accessor :label, :field_type, :required
    # =<br><b>FormField class for CloudFactory api entities.</b><br><br>
    # ==<b>Initializes a new form_field </b><br><br>
    # ---
    # <br>
    # * <b>Usage Example:</b><br><br>
    #     form_field = FormField.new(:label => "First Name", :field_type => "SA", :required => "true")
    #--
    def initialize(options={})
      @label      = options[:label]
      @field_type = options[:field_type]
      @required   = options[:required]
    end
  end
end