module MatureFactory::Features::Assemble::Strategies
  class Enumerate < Execute
    private
      def prepare_top
        MatureFactory::Features::Assemble::AbstractBuilder.
          link_with_delegation(top, strategy.object, strategy.step, delegate)
        top
      end
  end
end
