module MatureFactory
  module Features
    module Assemble
      module Builder
        DECORATION_ARTIFACTS_NAMES =
          %i(log title type proxy_class previous_step current_object delegate)

        def self.call(context, &on_create_proc)
          strategy = nil
          attrs = extract_values(BindingWrapper.new(context))
          if !attrs[:delegate].nil?
            strategy = DecorationComposition.new(*attrs.values)
          else
            strategy = FlatComposition.new(*attrs.values)
          end
          strategy.call(&on_create_proc)
        end

        def self.extract_values(context)
          {
            log: context.log,
            title: context.title,
            type: context.type,
            proxy_class: context.proxy_class,
            previous_step: context.previous_step,
            current_object: context.current_object,
            delegate: context.delegate
          }
        end

        private_class_method :extract_values

        class BindingWrapper < Struct.new(:context)
          def method_missing(name, *attrs, &block)
            context.local_variable_get(name) rescue nil
          end
        end

        class CompositionBuilder < Struct.new(*DECORATION_ARTIFACTS_NAMES)
          def observer_class; end
          def observer; end
          def result_class; end

          def call(&on_create_proc)
            log.each do |step, component_name|
              proxy = proxy_class.new(step, component_name)
              on_create_proc.call(proxy) if block_given?
              proxy.send(:create_object)
              proxy.after_create
              break if proxy.halt?
              observer.on_new_object(step, proxy.object)
            end
            observer.on_new_object(observer.previous_step, result_class.new)
            observer.current_object
          end
        end

        class DecorationComposition < CompositionBuilder
          def result_class
            proxy_class.superclass.public_send(:"#{title}_#{type}_struct_class")
          end

          def observer_class
            MatureFactory::Features::Assemble::WrappingObserver
          end

          def observer
            @observer ||= observer_class.new(previous_step, current_object, delegate)
          end
        end

        class FlatComposition < CompositionBuilder
          def result_class
            attrs_list = log.keys.unshift(previous_step).compact
            base_class = proxy_class.superclass.public_send(:"#{title}_#{type}_struct_class")
            base_class.class_eval { attr_accessor *attrs_list }
            base_class
          end

          def observer_class
            Class.new(SimpleDelegator) do
              attr_reader :previous_step
              def on_new_object(accessor, object)
                return if accessor.nil?
                __getobj__.public_send(:"#{accessor}=", object)
              end
              alias_method :current_object, :__getobj__
            end
          end

          def result_object
            result_class.new.tap do |result|
              result.send(:"#{previous_step}=", current_object) if current_object
            end
          end

          def observer
            @observer ||= observer_class.new(result_object)
          end
        end
      end
    end
  end
end
