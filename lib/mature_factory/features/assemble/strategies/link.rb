module MatureFactory::Features::Assemble::Strategies
  class Link < Struct.new(:strategy, :delegate)
    attr_reader :object, :step

    def call
      Enumerator.new do |yielder|
        strategy.call.inject(nil) do |object, (title, layer_object, id)|
          @object, @step = layer_object, id.title.to_sym
          if title.nil?
            yielder << [layer_object, id]
            next layer_object
          end
          MatureFactory::Features::Assemble::AbstractBuilder.
            link_with_delegation(layer_object, object, title, delegate)
          yielder << [layer_object, id]
          layer_object
        end
      end
    end
  end
end
