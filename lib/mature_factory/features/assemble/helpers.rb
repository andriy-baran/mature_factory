module MatureFactory
  module Features
    module Assemble
      module Helpers
        BUILDER_CLASS = MatureFactory::Features::Assemble::Builder
        PROXY_MODULE = MatureFactory::Features::Assemble::Proxy

        class Tracer < BasicObject
          def initialize(order)
            @logs = []
            @is_reverse_order = order == :reverse
          end

          def traced_method_names_with_attr_as_hash
            @logs.to_h
          end

          def method_missing(method_name, *attrs, &block)
            if @is_reverse_order
              @logs.unshift([attrs.first, method_name])
            else
              @logs.push([attrs.first, method_name])
            end
          end
        end

        def __mf_assembler_new_instance__(component_name, step, *attrs)
          mod = included_modules.detect {|m| m.respond_to?(:component_name) && m.component_name == component_name.to_s }
          if %i(flat wrap nest).include?(component_name)
            public_send(:"assemble_#{step}_struct")
          elsif !mod.nil?
            public_send(mod.__mf_new_instance_method_name__(step), *attrs)
          end
        end

        def __mf_assembler_execute_and_trace__(order: nil, &block)
          class_eval(&block)
          tracer = Tracer.new(order)
          tracer.instance_eval(&block)
          tracer.traced_method_names_with_attr_as_hash
        end

        def __mf_assembler_define_struct_assemble_method__(title, log, type, delegate)
          singleton_class.send(:define_method, :"assemble_#{title}_struct") do |previous_step = nil, current_object = nil, &on_create|
            raise(ArgumentError, 'Both arguments required') if previous_step.nil? ^ current_object.nil?
            proxy_class = Class.new(self) { include PROXY_MODULE }
            BUILDER_CLASS.call(binding, &on_create)
          end
        end
      end
    end
  end
end
