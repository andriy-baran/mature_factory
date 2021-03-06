module MatureFactory
	module SubclassingHelpers
    def __mf_prototype_define_init__(klass, &init)
      if block_given?
        klass.define_singleton_method(:__mf_init__, &init)
      elsif klass.superclass.respond_to?(:__mf_init__)
        parent_init = klass.superclass.method(:__mf_init__)
        klass.define_singleton_method(:__mf_init__, &parent_init)
      else
        default_init = ->(c, *attrs, &block) { c.new(*attrs, &block) }
        klass.define_singleton_method(:__mf_init__, &default_init)
      end
    end

    def __mf_prototype_patch_class__(base_class, &block)
      return base_class unless block_given?
      Class.new(base_class, &block)
    end

    def __mf_prototype_check_inheritance__!(component_class, base_class)
      return if component_class.nil? || base_class.nil?
      unless component_class <= base_class
        raise(ArgumentError, "must be a subclass of #{base_class.inspect}")
      end
    end
  end
end
