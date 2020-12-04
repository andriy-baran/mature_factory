module MatureFactory::Features::Assemble::Strategies
  class Reverse < Struct.new(:strategy)
    def call
      strategy.call.reverse_each
    end
  end
end
