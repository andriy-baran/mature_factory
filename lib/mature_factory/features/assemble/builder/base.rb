module MatureFactory
  module Features
    module Assemble
      module Builder
        class Base < Struct.new(*%i(log title type proxy_class previous_step current_object delegate))
          MMD_MODULE = MatureFactory::Features::Assemble::MethodMissingDecoration

          def observer_class
            Class.new(SimpleDelegator) do
              attr_reader :previous_step, :previous_object
              alias_method :current_object, :__getobj__
              def initialize(object, previous_step = nil, previous_object = nil)
                super(object)
                @previous_step = previous_step
                @previous_object = previous_object
              end
              def on_new_object(accessor, object)
                return if accessor.nil?
                current_object.facade_push(accessor, object)
                @previous_step = accessor
                @previous_object = object
              end
            end
          end

          def local_observer
            @local_observer ||= observer_class.new(result_object, previous_step, current_object)
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
              halt = false
              log.each do |step, component_name|
                halt = build_component(step, component_name, halt, &on_create_proc)
              end
            end
          end

          def build_component(step, component_name, halt, &block)
            proxy = proxy_class.new(step, component_name, halt, &block)
            local_observer.on_new_object(step, proxy.object)
            throw :halt if proxy.halt?
            proxy.halt?
          end
        end
      end
    end
  end
end
