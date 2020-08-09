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
      end
    end
  end
end
