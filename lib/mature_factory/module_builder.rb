module MatureFactory
	class ModuleBuilder < Module
    private_class_method :new

    module Setup
      def self.extended(receiver)
        class << receiver
          attr_accessor :component_name, :components_name
        end
      end

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

    def self.inflector
      MatureFactory.inflector
    end

		def self.call(components_name)
			new.tap do |mod|
        mod.extend Setup
        mod.extend MatureFactory::DSL
        mod.components_name = components_name
        mod.component_name = inflector.singularize(components_name)
        mod.define_components_registry
        mod.define_component_adding_method
        mod.define_component_store_method
        mod.define_component_activation_method
      end
		end
	end
end
