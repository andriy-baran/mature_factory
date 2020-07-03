module MatureFactory
  module Features
    module Assemble
      module Helpers
        BUILDER_CLASS = MatureFactory::Features::Assemble::Builder
        PROXY_MODULE = MatureFactory::Features::Assemble::Proxy

        class Tracer
          attr_reader :log
          def initialize
            @log = {}
          end

          def method_missing(method_name, *attrs, &block)
            @log[attrs.first] = method_name
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
          tracer = Tracer.new
          tracer.instance_eval(&block)
          case order
          when :direct
            tracer.log.each
          when :reverse
            tracer.log.reverse_each
          else
            tracer.log
          end
        end

        def __mf_assembler_define_struct_assemble_method__(title, log, break_if, delegate)
          singleton_class.send(:define_method, :"assemble_#{title}_struct") do |previous_step = nil, current_object = nil, break_if: break_if, &on_create|
            raise(ArgumentError, 'Both arguments required') if previous_step.nil? ^ current_object.nil?
            proxy_class = Class.new(self) { include PROXY_MODULE }
            BUILDER_CLASS.call(binding, &on_create)
          end
        end
      end
    end
  end
end
