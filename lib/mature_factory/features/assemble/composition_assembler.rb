module MatureFactory
  module Features
    module Assemble
      module CompositionAssembler
        DECORATION_ARTIFACTS_NAMES =
          %i(log previous_step current_object break_if after_create delegate)

        def self.call(context, &create_proc)
          strategy = nil
          attrs = extract_values(BindingWrapper.new(context))
          if !attrs[:delegate].nil?
            strategy = DecorationComposition.new(*attrs.values)
          else
            strategy = FlatComposition.new(*attrs.values)
          end
          strategy.call(&create_proc)
        end

        def self.extract_values(context)
          {
            log: context.log,
            previous_step: context.previous_step,
            current_object: context.current_object,
            break_if: context.break_if,
            after_create: context.after_create,
            delegate: context.delegate
          }
        end

        private_class_method :extract_values

        class BindingWrapper < Struct.new(:context)
          def method_missing(name, *attrs, &block)
            context.local_variable_get(name) rescue nil
          end
        end

        class DecorationComposition < Struct.new(*DECORATION_ARTIFACTS_NAMES)
          OBSERVER_CLASS = MatureFactory::Features::Assemble::WrappingObserver

          def call(&create_proc)
            log.each do |step, component_name|
              next_object = create_proc.call(component_name, step)
              after_create.call(step, next_object) unless after_create.nil?
              break if !break_if.nil? && break_if.call(step, next_object)
              observer.on_new_object(step, next_object)
            end
            observer.on_new_object(observer.previous_step, Object.new)
            observer.current_object
          end

          def observer
            @observer ||= OBSERVER_CLASS.new(previous_step, current_object, delegate)
          end
        end

        class FlatComposition < Struct.new(*DECORATION_ARTIFACTS_NAMES)
          def attrs_list
            log.keys.unshift(previous_step).compact
          end

          def res_struct_class
            Class.new(Struct.new(*attrs_list))
          end

          def call(&create_proc)
            objects = [current_object].compact
            log.each do |step, component_name|
              next_object = create_proc.call(component_name, step)
              after_create.call(step, next_object) unless after_create.nil?
              break if !break_if.nil? && break_if.call(step, next_object)
              objects << next_object
            end
            res_struct_class.new(*objects)
          end
        end
      end
    end
  end
end
