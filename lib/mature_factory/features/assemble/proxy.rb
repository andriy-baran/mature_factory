module MatureFactory::Features::Assemble
  class Proxy
    def initialize(target)
      @target = target
    end

    def call(&block)
      @target.call(&block)
    end
  end
end
