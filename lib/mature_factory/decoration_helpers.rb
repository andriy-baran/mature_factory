module MatureFactory
	module DecorationHelpers
    def __mf_composite_define_init__(klass, &init)
      if block_given?
        klass.define_singleton_method(:__mf_init__, &init)
      elsif klass.superclass.respond_to?(:__mf_init__)
        klass.define_singleton_method(:__mf_init__, &klass.superclass.method(:__mf_init__))
      else
        default_init = ->(klass, *attrs, &block) { klass.new(*attrs, &block) }
        klass.define_singleton_method(:__mf_init__, &default_init)
      end
    end

    def __mf_composite_patch_class__(base_class, &block)
      return base_class unless block_given?
      Class.new(base_class, &block)
    end

    def __mf_composite_check_inheritance__!(component_class, base_class)
      return if component_class.nil?
      unless component_class <= base_class
        raise(ArgumentError, "must be a subclass of #{base_class.name}")
      end
    end
  end
end
