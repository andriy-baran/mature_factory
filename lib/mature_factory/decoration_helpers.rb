module MatureFactory
	module DecorationHelpers
    def __mf_composite_define_init__(klass, &init)
      return klass unless block_given?
      klass.singleton_class.send(:define_method, :__mf_init__, &init)
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
