module MatureFactory
  module Features
    module Assemble
      module Helpers
        ASSEMBLER = MatureFactory::Features::Assemble::CompositionAssembler

        class Tracer
          attr_reader :log
          def initialize
            @log = {}
          end

          def method_missing(method_name, *attrs, &block)
            @log[attrs.first] = method_name
          end
        end

        private

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

        def __mf_assembler_define_flat_struct_assemble_method__(title = log.to_a.first.first, log, break_if)
          title = log.to_h.keys.first if title.nil?
          singleton_class.send(:define_method, :"assemble_#{title}_struct") do |previous_step = nil, current_object = nil, break_if: break_if, &after_create|
            raise(ArgumentError, 'Both arguments required') if previous_step.nil? ^ current_object.nil?
            ASSEMBLER.call(binding) do |component_name, step|
              __mf_assembler_new_instance__(component_name, step)
            end
          end
        end

        def __mf_assembler_define_layered_struct_assemble_method__(title = nil, log, break_if, delegate)
          title = log.to_h.keys.first if title.nil?
          singleton_class.send(:define_method, :"assemble_#{title}_struct") do |previous_step = nil, current_object = nil, break_if: break_if, &after_create|
            raise(ArgumentError, 'Both arguments required') if previous_step.nil? ^ current_object.nil?
            ASSEMBLER.call(binding) do |component_name, step|
              __mf_assembler_new_instance__(component_name, step)
            end
          end
        end
      end
    end
  end
end
