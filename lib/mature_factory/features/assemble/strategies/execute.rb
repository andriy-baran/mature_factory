module MatureFactory::Features::Assemble::Strategies
  class Execute < Struct.new(:strategy, :top, :delegate)
    def call(&block)
      catch(:halt) do
        build_plan = strategy.call
        block_given? ? build_plan.each(&block) : build_plan.to_a
      end
      prepare_top
    end

    private

    def prepare_top
      top
    end
  end
end
