module MatureFactory
  module Features
    module Assemble
      module Builder
        class Base < Struct.new(*%i(log title type proxy_class previous_step current_object delegate))
          MMD_MODULE = MatureFactory::Features::Assemble::MethodMissingDecoration

          def observer_class
            Class.new(SimpleDelegator) do
              attr_reader :previous_step
              alias_method :current_object, :__getobj__
              def initialize(object, previous_step = nil)
                super(object)
                @previous_step = previous_step
              end
              def on_new_object(accessor, object)
                return if accessor.nil?
                current_object.facade_push(accessor, object)
                @previous_step = accessor
              end
            end
          end

          def local_observer
            @local_observer ||= observer_class.new(result_object, previous_step)
          end

          def result_object
            @result_object ||= begin
              result = proxy_class.superclass.public_send(:"new_#{title}_#{type}_struct_instance")
              result.facade_push(previous_step, current_object) if current_object
              result
            end
          end

          private

          def build_components(&on_create_proc)
            catch :halt do
              log.each do |step, component_name|
                build_component(step, component_name, &on_create_proc)
              end
            end
          end

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
