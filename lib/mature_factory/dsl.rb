module MatureFactory
	module DSL
		def define_component_store_method
	    mod = self
	    define_method(:"#{mod.__mf_store_method_name__}") do |method_name, klass|
	      send(:"#{mod.__mf_component_class_reader__(method_name)}=", klass)
	      public_send(:"#{mod.__mf_registry_method_name__}")[method_name] = klass
	    end
	  end

	  def define_component_activation_method
	    mod = self
	    define_method(:"__mf_activate_#{mod.component_name}_component__") do |method_name, base_class, klass, init = nil, &block|
	      component_class = public_send(:"#{mod.__mf_registry_method_name__}")[method_name] # inherited
	      raise(ArgumentError, 'please provide a block or class') if component_class.nil? && klass.nil? && block.nil?

	      target_class = component_class || klass || base_class

	      __mf_composite_check_inheritance__!(target_class, base_class)

	      patched_class = __mf_composite_patch_class__(target_class, &block)
	      __mf_composite_define_init__(patched_class, &init)
	      public_send(mod.__mf_store_method_name__, method_name, patched_class)
	    end
	  end

	  def define_component_new_instance_method(method_name)
	    mod = self
	    define_method mod.__mf_new_instance_method_name__(method_name) do |*args|
	      klass = public_send(mod.__mf_component_class_reader__(method_name))
	      klass.__mf_init__(klass, *args)
	    end
	  end

	  def define_component_configure_method(method_name)
	    mod = self
	    define_method :"#{method_name}_#{mod.component_name}" do |klass = nil, init: nil, &block|
	      base_class = public_send(:"#{mod.__mf_component_class_reader__(method_name)}")
	      public_send(mod.__mf_activation_method_name__, method_name, base_class, klass, init, &block)
	    end
	  end

	  def define_component_adding_method
	    mod = self
	    default_init = ->(klass, *attrs) { klass.new }
	    define_method(component_name.to_sym) do |method_name, base_class: Class.new, init: default_init|
	      singleton_class.class_eval do
	        attr_accessor :"#{mod.__mf_component_class_reader__(method_name)}"
	        private :"#{mod.__mf_component_class_reader__(method_name)}="
	      end
	      __mf_composite_define_init__(base_class, &init)
	      send(:"#{mod.__mf_component_class_reader__(method_name)}=", base_class)
	      mod.define_component_configure_method(method_name)
	      mod.define_component_new_instance_method(method_name)
	    end
	  end

	  def define_components_registry
	    mod = self
	    module_eval <<-METHOD, __FILE__, __LINE__ + 1
	      def #{mod.__mf_registry_method_name__}
	        @#{mod.__mf_registry_method_name__} ||= {}
	      end
	    METHOD
	  end
	end
end
