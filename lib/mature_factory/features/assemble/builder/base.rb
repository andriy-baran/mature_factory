module MatureFactory
  module Features
    module Assemble
      module Builder
        class Base < Struct.new(*DECORATION_ARTIFACTS_NAMES)
          MMD_MODULE = MatureFactory::Features::Assemble::MethodMissingDecoration

          def observer_class
            Class.new(SimpleDelegator) do
              attr_reader :previous_step
              alias_method :current_object, :__getobj__
              def on_new_object(accessor, object)
                return if accessor.nil?
                current_object.facade_push(accessor, object)
              end
            end
          end

          def local_observer
            @local_observer ||= observer_class.new(result_object)
          end

          def result_object
            @result_object ||= begin
              result = proxy_class.superclass.public_send(:"new_#{title}_#{type}_struct_instance")
              result.facade_push(previous_step, current_object) if current_object
              result
            end
          end

          def call(&on_create_proc)
            catch :halt do
              log.each do |step, component_name|
                build_component(step, component_name, &on_create_proc)
              end
            end
            local_observer.on_new_object(local_observer.previous_step, result_object) unless type == :flatten
            return local_observer.current_object if type == :flatten
            obj = local_observer.link_members
            while delegate && (obj.predecessor rescue false)
              obj = obj.public_send(obj.predecessor).extend(MMD_MODULE)
            end
            local_observer.current_object
          end

          private

          def build_component(step, component_name, &block)
            proxy = proxy_class.new(step, component_name, &block)
            throw :halt if proxy.halt? && type != :flatten
            local_observer.on_new_object(step, proxy.__object__)
            throw :halt if proxy.halt? && type == :flatten
          end
        end
      end
    end
  end
end
