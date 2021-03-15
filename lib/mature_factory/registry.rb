module MatureFactory
  class Registry
    def initialize(on_missing_key:)
      @modules = {}
      @on_missing_key = on_missing_key
    end

    def resolve(components_name, **attrs)
      find(components_name) || build(components_name, attrs)
    end

    def registered_modules
      @modules.values
    end

    private

    def find(module_name)
      @modules[module_name]
    end

    def register(module_name, module_instance)
      @modules[module_name] = module_instance
    end

    def build(components_name, **attrs)
      register(components_name, @on_missing_key.call(components_name, attrs))
    end
  end
end
