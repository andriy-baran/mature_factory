module MatureFactory
  module Features
    module Assemble
      module Proxy
        def initialize(title, component_name, &block)
          @title = title
          @component_name = component_name
          @halt = false
          @object = nil
          yield self if block_given?
          __create_object__ if @object.nil?
        end

        def __object__
          @object
        end

        def method_missing(method_name, *attrs, &block)
          if method_name.end_with?('?')
            method_name == :"#{@title}?"
          elsif method_name.end_with?('=')
            super
          else
            return if method_name != @title
            __create_object__(*attrs)
            yield @object if block_given?
          end
        end

        def halt?
          @halt
        end

        def halt!
          @halt = true
        end

        private

        def __create_object__(*attrs)
          @object = self.class.superclass.__mf_assembler_new_instance__(@component_name, @title, *attrs)
        end
      end
    end
  end
end
