module MatureFactory
	module ModuleBuilder
		def self.call
			Module.new do
				extend MatureFactory::DSL

        class << self
          attr_accessor :component_name, :components_name

          def included(receiver)
            receiver.extend self
          end

          def extended(receiver)
            receiver.extend MatureFactory::DecorationHelpers
            receiver.extend MatureFactory::InheritanceHelpers
          end

          def __mf_store_method_name__(title = component_name)
            :"__mf_store_#{title}_class__"
          end

          def __mf_activation_method_name__(title = component_name)
            :"__mf_activate_#{title}_component__"
          end

          def __mf_new_instance_method_name__(title)
            :"new_#{title}_#{component_name}_instance"
          end

          def __mf_component_class_reader__(title)
            :"#{title}_#{component_name}_class"
          end
        end
      end
		end
	end
end
