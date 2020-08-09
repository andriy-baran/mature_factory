module MatureFactory
  module Features
    module Assemble
      module Builder
        class Base < Struct.new(*DECORATION_ARTIFACTS_NAMES)
          def observer_class; end
          def local_observer; end
          def result_object
            @result_object ||= proxy_class.superclass.public_send(:"new_#{title}_#{type}_struct_instance")
          end

          def call(&on_create_proc)
            catch :halt do
              log.each do |step, component_name|
                build_component(step, component_name, &on_create_proc)
              end
            end
            local_observer.on_new_object(local_observer.previous_step, result_object) unless type == :flatten
            local_observer.current_object
          end

          private

          def build_component(step, component_name, &block)
            proxy = proxy_class.new(step, component_name)
            block.call(proxy) if block_given?
            throw :halt if proxy.halt? && type != :flatten
            proxy.send(:create_object)
            proxy.after_create
            local_observer.on_new_object(step, proxy.object)
            throw :halt if proxy.halt? && type == :flatten
          end
        end
      end
    end
  end
end
