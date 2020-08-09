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
          def result_object
            @result_object ||= proxy_class.superclass.public_send(:"new_#{title}_#{type}_struct_instance")
          end

          def call(&on_create_proc)
            log.each do |step, component_name|
              proxy = proxy_class.new(step, component_name)
              on_create_proc.call(proxy) if block_given?
              break if proxy.halt? && type != :flatten
              proxy.send(:create_object)
              proxy.after_create
              observer.on_new_object(step, proxy.object)
              break if proxy.halt? && type == :flatten
            end
            observer.on_new_object(observer.previous_step, result_object) unless type == :flatten
            observer.current_object
          end
        end

        class DecorationComposition < CompositionBuilder
          def observer_class
            MatureFactory::Features::Assemble::WrappingObserver
          end

          def observer
            @observer ||= observer_class.new(previous_step, current_object, delegate)
          end
        end

        class FlatComposition < CompositionBuilder
          def observer_class
            Class.new(SimpleDelegator) do
              attr_reader :previous_step
              alias_method :current_object, :__getobj__
              def on_new_object(accessor, object)
                return if accessor.nil?
                current_object.public_send(:"#{accessor}=", object)
              end
            end
          end

          def result_object
            @result_object ||= begin
              attrs_list = log.keys.unshift(previous_step).compact
              proxy_class.superclass.public_send(:"#{title}_#{type}_struct") { attr_accessor *attrs_list }
              super.tap do |result|
                result.send(:"#{previous_step}=", current_object) if current_object
              end
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
