module MatureFactory
	module DSL
		def define_component_store_method(receiver, title)
	    mod = self
	    receiver.define_singleton_method(mod.__mf_store_method_name__(title)) do |klass|
	    	base_class = public_send(:"#{mod.__mf_local_registry_name__}")[title]
	    	__mf_prototype_check_inheritance__!(klass, base_class)
	      send(mod.__mf_simple_store_method_name__(title), klass)
	    end
	  end

	  def define_component_simple_store_method(receiver, title)
	    mod = self
	    receiver.define_singleton_method(mod.__mf_simple_store_method_name__(title)) do |klass|
	      send(:"write_#{mod.__mf_component_class_reader__(title)}", klass)
	      public_send(:"#{mod.__mf_local_registry_name__}")[title] = klass
	    end
	    receiver.private_class_method mod.__mf_simple_store_method_name__(title)
	  end

	  def define_component_activation_method
	    mod = self
	    define_method(:"__mf_activate_#{mod.component_name}_component__") do |title, base_class, klass, init = nil, &block|
	      # component_class = public_send(:"#{mod.__mf_local_registry_name__}")[title] # inherited
	      raise(ArgumentError, 'please provide a block or class') if klass.nil? && block.nil?
	      __mf_prototype_check_inheritance__!(klass, base_class)

	      target_class = klass || base_class

	      patched_class = __mf_prototype_patch_class__(target_class, &block)
	      __mf_prototype_define_init__(patched_class, &init)
	      public_send(mod.__mf_store_method_name__(title), patched_class)
	    end
	  end

	  def define_component_new_instance_method(title)
	    mod = self
	    define_method mod.__mf_new_instance_method_name__(title) do |*args|
	      klass = public_send(mod.__mf_component_class_reader__(title))
	      klass.__mf_init__(klass, *args)
	    end
	  end

	  def define_component_configure_method(title)
	    mod = self
	    define_method :"#{title}_#{mod.component_name}" do |klass = nil, init: nil, &block|
	      base_class = public_send(:"#{mod.__mf_component_class_reader__(title)}")
	      public_send(mod.__mf_activation_method_name__, title, base_class, klass, init, &block)
	    end
	    private :"#{title}_#{mod.component_name}"
	  end

	  def define_component_adding_method
	    mod = self
	    define_method(component_name.to_sym) do |title, base_class: nil, init: nil|
	      singleton_class.class_eval do
	        attr_accessor :"#{mod.__mf_component_class_reader__(title)}"
	        alias_method :"write_#{mod.__mf_component_class_reader__(title)}", :"#{mod.__mf_component_class_reader__(title)}="
	      end
	      klass = base_class || mod.default_base_class || Class.new(Object)
	      __mf_prototype_define_init__(klass, &(init || mod.default_init))
	      mod.define_component_store_method(self, title)
	      mod.define_component_simple_store_method(self, title)
	      send(mod.__mf_simple_store_method_name__(title), klass)
	      mod.define_component_configure_method(title)
	      mod.define_component_new_instance_method(title)
	    end
	  end

	  def define_components_registry
	    mod = self
	    module_eval <<-METHOD, __FILE__, __LINE__ + 1
	      def #{mod.__mf_local_registry_name__}
	        @#{mod.__mf_local_registry_name__} ||= {}
	      end
	    METHOD
	  end
	end
end
