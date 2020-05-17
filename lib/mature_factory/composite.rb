module MatureFactory
  class Composite
    def self.[](components_name)
      registry.resolve(components_name)
    end

    def self.registered_modules
      registry.registered_modules
    end

    def self.build_module
      ->(components_name) { ModuleBuilder.call(components_name) }
    end

    def self.registry
      @registry ||= Registry.new(on_missing_key: build_module)
    end

    private_class_method :registry, :build_module
  end
end
