module MatureFactory
  module Features
    module Assemble
      module Proxy
        attr_accessor :init_with
        attr_reader :object, :title

        def initialize(title, component_name)
          @title = title
          @component_name = component_name
          @halt = false
          @object = nil
          @after_create = proc {}
        end

        def after_create(&block)
          block_given? ? @after_create = block : @after_create.call(@object)
        end

        def halt?
          @halt
        end

        def halt!
          @halt = true
        end

        private

        def create_object
          @object = self.class.superclass.__mf_assembler_new_instance__(@component_name, @title, *init_with)
        end
      end
    end
  end
end
