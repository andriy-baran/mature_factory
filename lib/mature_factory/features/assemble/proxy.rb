module MatureFactory
  module Features
    module Assemble
      module Proxy
        attr_reader :title, :group, :object

        def initialize(title, group, halt, &block)
          @title = title
          @group = group
          @halt = halt
          @object = nil
          @on_create_proc = nil
          instance_eval(&block) if block_given?
          __create_object__ if @object.nil?
        end

        def on_create(&block)
          @on_create_proc = block
        end

        def method_missing(method_name, *attrs, &block)
          if method_name.to_s.end_with?('?')
            method_name == :"#{identity}?"
          elsif method_name.to_s.end_with?('=')
            super
          else
            return if method_name != identity
            __create_object__(*attrs)
            yield @object if block_given?
            @object
          end
        end

        def halt?
          @halt
        end

        def halt!
          @halt = true
        end

        private

        def identity
          :"#{@group}_#{@title}"
        end

        def __create_object__(*attrs)
          @object = self.class.superclass.__mf_assembler_new_instance__(@group, @title, *attrs)
          instance_eval(&@on_create_proc) if @on_create_proc
        end
      end
    end
  end
end
