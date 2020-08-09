module MatureFactory
  module Features
    module Assemble
      module Builder
        class FlatComposition < Base
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

          def local_observer
            @local_observer ||= observer_class.new(result_object)
          end
        end
      end
    end
  end
end
