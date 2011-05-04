module CloudFactory
  class CustomInstruction

    attr_accessor :title, :description, :html, :css, :javascript

    def initialize(options={})
      @title       = options[:title]
      @description = options[:description]
    end

    def self.create(instruction, &block)
      instruction = CustomInstruction.new(instruction)
      if block.arity >= 1
        block.call(instruction)
      else
        instruction.instance_eval &block
      end
      instruction
    end

    def html html = nil
      if html
        @html = html
      else
        @html
      end
    end

    def css css = nil
      if css
        @css = css
      else
        @css
      end
    end

    def javascript javascript = nil
      if javascript
        @javascript = javascript
      else
        @javascript
      end
    end

  end
end