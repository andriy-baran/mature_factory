module MatureFactory
  class Prototype
    def self.[](components_name, base_class: nil, init: nil)
      registry.resolve(components_name) do |mod|
        mod.default_base_class = base_class if base_class
        mod.default_init = init if init
      end
    end

    def self.registered_modules
      registry.registered_modules
    end

    def self.build_module
      -> (components_name, &block) do
        ModuleBuilder.call(components_name, &block)
      end
    end

    def self.registry
      @registry ||= Registry.new(on_missing_key: build_module)
    end

    private_class_method :registry, :build_module
  end
end
