module MatureFactory::Features::Assemble::Strategies
  class Execute
    MMD_MODULE = MatureFactory::Features::Assemble::MethodMissingDecoration

    attr_reader :step

    def initialize(pipe, trace)
      @pipe = pipe
      @trace = trace.tap(&:call)
    end

    def call(delegate)
      @pipe.inject(nil) do |object, (title, init_proc, id)|
        @step = id.title.to_sym
        init_params = @trace.init_params[id.to_sym]
        layer_object = init_params.nil? ? init_proc.call : init_proc.call(*init_params)
        next layer_object if title.nil?
        layer_object.define_singleton_method(:__mf_predecessor__) { title }
        layer_object.define_singleton_method(title) { object }
        layer_object.extend(MMD_MODULE) if delegate
        break layer_object if @trace.halt_proc&.call(layer_object, id)
        layer_object
      end
    end
  end
end
