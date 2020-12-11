module MatureFactory::Features::Assemble::Strategies
  class Init < Struct.new(:strategy, :pipe)
    def call
      Enumerator.new do |yielder|
        init_params = strategy.call
        pipe.each do |title, init_proc, id|
          init_attrs = Array(init_params[id.to_sym])
          layer_object = init_proc.call(*init_attrs)
          yielder << [title, layer_object, id]
        end
      end.lazy
    end
  end
end
