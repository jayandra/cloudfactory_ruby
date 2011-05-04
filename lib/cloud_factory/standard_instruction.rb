module CloudFactory
  class StandardInstruction
    
    attr_accessor :title, :description, :form_fields

    def initialize(options={})
      @title       = options[:title]
      @description = options[:description]
    end
    
    def self.create(instruction, &block)
      instruction = StandardInstruction.new(instruction)
      if block.arity >= 1
        block.call(instruction)
      else
        instruction.instance_eval &block
      end
      instruction
    end
    
    def form_fields form_fields = nil
      if form_fields
        @form_fields = form_fields
      else
        @form_fields
      end
    end
  end
end