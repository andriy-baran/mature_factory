module MatureFactory::Features::Assemble::Strategies
  class Mount < Struct.new(:strategy, :pipe, :top, :step)
    def call
      Enumerator.new do |yielder|
        init_params = strategy.call
        pipe.each do |id, init_proc|
          self.step = id.title.to_sym
          init_attrs = Array(init_params[id.to_sym])
          layer_object = init_proc.call(*init_attrs)
          top.define_singleton_method(id.title.to_sym) { layer_object }
          yielder << [layer_object, id]
        end
      end
    end
  end
end
