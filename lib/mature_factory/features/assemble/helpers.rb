module MatureFactory
  module Features
    module Assemble
      module Helpers
        class Tracer
          attr_reader :log
          def initialize
            @log = {}
          end

          def method_missing(method_name, *attrs, &block)
            @log[attrs.first] = method_name
          end
        end

        class WrappingObserver
          MMD_MODULE = MatureFactory::Features::Assemble::MethodMissingDecoration

          attr_reader :current_object, :previous_step

          def initialize(previous_step = nil, current_object = nil, delegate)
            @previous_step = previous_step
            @current_object = current_object
            @delegate = delegate
          end

          def on_new_object(accessor, object)
            @current_object = wrap(@current_object, object, @previous_step, @delegate)
            @previous_step = accessor
          end

          def wrap(current_object, wrapper_object, accessor, delegate)
            return wrapper_object if accessor.nil? || current_object.nil?
            wrapper_object.singleton_class.class_eval do
              attr_accessor :__mf_assembler_predecessor__
            end
            wrapper_object.__mf_assembler_predecessor__ = accessor
            wrapper_object.extend(MMD_MODULE) if delegate
            wrapper_object.singleton_class.class_eval do
              attr_accessor wrapper_object.__mf_assembler_predecessor__
            end
            wrapper_object.public_send(:"#{wrapper_object.__mf_assembler_predecessor__}=", current_object)
            wrapper_object
          end
        end

        private

        def __mf_assembler_new_instance__(component_name, step, *attrs)
          mod = included_modules.detect {|m| m.respond_to?(:component_name) && m.component_name == component_name.to_s }
          public_send(mod.__mf_new_instance_method_name__(step), *attrs)
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

        def __mf_assembler_define_flat_struct_assemble_method__(title, log, break_if)
          singleton_class.send(:define_method, :"assemble_#{title}_struct") do |previous_step = nil, current_object = nil, break_if: break_if, &after_create|
            raise(ArgumentError, 'Both arguments required') if previous_step.nil? ^ current_object.nil?
            attrs_list = log.keys.unshift(previous_step).compact
            res_struct_class = Class.new(Struct.new(*attrs_list))
            objects = [current_object].compact
            log.each do |step, component_name|
              next_object = __mf_assembler_new_instance__(component_name, step)
              after_create.call(step, next_object) unless after_create.nil?
              break if !break_if.nil? && break_if.call(step, next_object)
              objects << next_object
            end
            res_struct_class.new(*objects)
          end
        end

        def __mf_assembler_define_layered_struct_assemble_method__(title, log, delegate, break_if)
          singleton_class.send(:define_method, :"assemble_#{title}_struct") do |previous_step = nil, current_object = nil, break_if: break_if, &after_create|
            raise(ArgumentError, 'Both arguments required') if previous_step.nil? ^ current_object.nil?
            observer = WrappingObserver.new(previous_step, current_object, delegate)
            log.each do |step, component_name|
              next_object = __mf_assembler_new_instance__(component_name, step)
              after_create.call(step, next_object) unless after_create.nil?
              break if !break_if.nil? && break_if.call(step, next_object)
              observer.on_new_object(step, next_object)
            end
            observer.current_object
          end
        end
      end
    end
  end
end
