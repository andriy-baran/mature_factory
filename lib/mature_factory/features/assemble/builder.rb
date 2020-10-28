module MatureFactory
  module Features
    module Assemble
      module Builder
        BUILD_STRATEGIES = {
          flatten: Builder::Flat,
          wrapped: Builder::Wrap,
          nested: Builder::Nest,
        }

        def self.call(context, &on_create_proc)
          attrs = extract_values(BindingWrapper.new(context))
          strategy = BUILD_STRATEGIES[attrs[:type]].new(*attrs.values)
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
