module MatureFactory
	class ModuleBuilder < Module
    private_class_method :new

    module Setup
      def self.extended(receiver)
        class << receiver
          attr_accessor :component_name, :components_name,
            :default_base_class, :default_init
        end
      end

      def included(receiver)
        receiver.extend self
      end

      def extended(receiver)
        receiver.extend MatureFactory::SubclassingHelpers
        receiver.extend MatureFactory::InheritanceHelpers
        receiver.private_class_method :__mf_prototype_define_init__
        receiver.private_class_method :__mf_prototype_patch_class__
        receiver.private_class_method :__mf_prototype_check_inheritance__!
        receiver.private_class_method :__mf_inheritance_store_parent_components_of_composite__
        receiver.private_class_method :__mf_inheritance_activate_parent_components_of_composite__
        receiver.private_class_method :__mf_inheritance_reactivate_composites__
      end

      def __mf_global_registry_id__
        MatureFactory.global_registry_module_id(components_name,
          base_class: default_base_class,
          init: default_init
        )
      end

      def __mf_local_registry_name__(title = components_name)
        :"mf_#{title}"
      end

      def __mf_simple_store_method_name__(name)
        :"__mf_simple_store_#{__mf_component_class_reader__(name)}_class__"
      end

      def __mf_store_method_name__(name)
        :"#{__mf_component_class_reader__(name)}="
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

		def self.call(components_name, **attrs)
			new.tap do |mod|
        mod.extend Setup
        mod.components_name = components_name
        mod.component_name = inflector.singularize(components_name)
        mod.default_base_class = attrs[:base_class]
        mod.default_init = attrs[:init]
        mod.extend MatureFactory::DSL
        mod.define_components_registry
        mod.define_component_adding_method
        mod.define_component_activation_method
      end
		end
	end
end
