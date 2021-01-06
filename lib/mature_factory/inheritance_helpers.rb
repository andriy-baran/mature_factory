module MatureFactory
	module InheritanceHelpers
    def inherited(subclass)
      subclass.send(:__mf_inheritance_reactivate_composites__)
    end

    def __mf_inheritance_reactivate_composites__
      __mf_included_composite_modules__.each do |composite|
        __mf_inheritance_store_parent_components_of_composite__(composite)
        __mf_inheritance_activate_parent_components_of_composite__(composite)
      end
    end

    def __mf_included_composite_modules__
      MatureFactory.registered_modules & included_modules
    end

    def __mf_inheritance_store_parent_components_of_composite__(composite)
      readers_regexp = Regexp.new("\\w+_#{composite.component_name}_class\\z")
      superclass.public_methods.grep(readers_regexp).grep_v(/write_/).each do |reader_method|
        klass = superclass.public_send(reader_method)
        send(:"#{reader_method}=", klass)
      end
    end

    def __mf_inheritance_activate_parent_components_of_composite__(composite)
      superclass.public_send("#{composite.__mf_registry_method_name__}").each do |component, klass|
        public_send(composite.__mf_store_method_name__(component), klass)
      end
    end
  end
end
