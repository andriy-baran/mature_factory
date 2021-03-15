module MatureFactory
  class Prototype
    def self.build(components_name, **attrs)
      registry.resolve(components_name, attrs)
    end

    def self.registered_modules
      registry.registered_modules
    end

    def self.build_module
      -> (components_name, **attrs) do
        ModuleBuilder.call(components_name, attrs)
      end
    end

    def self.registry
      @registry ||= Registry.new(on_missing_key: build_module)
    end

    private_class_method :registry, :build_module
  end
end
