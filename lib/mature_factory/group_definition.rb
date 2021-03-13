module MatureFactory
  class GroupDefinition
    attr_reader :definitions

    def initialize
      @definitions = {}
    end

    def method_missing(name, **kw, &block)
      @definitions[name] = kw.keep_if { |key, _|
        %i(base_class init).include?(key)
      }
    end
  end
end
