require 'mature_factory/features/assemble/strategies/trace'
require 'mature_factory/features/assemble/strategies/reverse'
require 'mature_factory/features/assemble/strategies/prepare'
require 'mature_factory/features/assemble/strategies/transform'
require 'mature_factory/features/assemble/strategies/execute'
require 'mature_factory/features/assemble/strategies/trace_build'

module MatureFactory::Features::Assemble
  class AbstractBuilder < Struct.new(:factory)
    MMD_MODULE = MatureFactory::Features::Assemble::MethodMissingDecoration

    def nest(name, delegate, &block)
      factory.class_eval(&block)
      factory.define_singleton_method(:"build_#{name}") do |title = nil, object = nil, &on_create|
        raise(ArgumentError, 'Both arguments required') if title.nil? ^ object.nil?
        trace = Strategies::Trace.new(&block)
        reverse = Strategies::Reverse.new(trace)
        prepare = Strategies::Prepare.new(reverse, self)
        pipe = Strategies::Transform.new(prepare, title, object).call
        list = pipe.map(&:last).map(&:to_sym)
        trace_build = Strategies::TraceBuild.new(list, &on_create)
        execute = Strategies::Execute.new(pipe, trace_build)
        result = execute.call(delegate)
        top = public_send(:"new_#{name}_nested_struct_instance")
        top.define_singleton_method(:__mf_predecessor__) { execute.step }
        top.define_singleton_method(execute.step) { result }
        top.extend(MMD_MODULE) if delegate
        top
      end
    end

    def wrap(name, delegate, &block)
      factory.class_eval(&block)
      factory.define_singleton_method(:"build_#{name}") do |title = nil, object = nil, &on_create|
        raise(ArgumentError, 'Both arguments required') if title.nil? ^ object.nil?
        trace = Strategies::Trace.new(&block)
        prepare = Strategies::Prepare.new(trace, self)
        pipe = Strategies::Transform.new(prepare, title, object).call
        list = pipe.map(&:last).map(&:to_sym)
        trace_build = Strategies::TraceBuild.new(list, &on_create)
        execute = Strategies::Execute.new(pipe, trace_build)
        result = execute.call(delegate)
        top = public_send(:"new_#{name}_wrapped_struct_instance")
        top.define_singleton_method(:__mf_predecessor__) { execute.step }
        top.define_singleton_method(execute.step) { result }
        top.extend(MMD_MODULE) if delegate
        top
      end
    end

    def flat(name, &block)
      factory.class_eval(&block)
      factory.define_singleton_method(:"build_#{name}") do |title = nil, object = nil, &on_create|
        raise(ArgumentError, 'Both arguments required') if title.nil? ^ object.nil?

        trace = Strategies::Trace.new(&block)
        prepare = Strategies::Prepare.new(trace, self)
        list = prepare.call.to_a
        list.unshift([nil, title, proc{object}]) unless object.nil?
        list = list.transpose
        ids = list[0..1].transpose.map{|g,e| MatureFactory::Features::Assemble::Id.new(g,e)}
        trace_build = Strategies::TraceBuild.new(ids.map(&:to_sym), &on_create).tap(&:call)
        step = title
        top = public_send(:"new_#{name}_flatten_struct_instance")
        ids.zip(list[-1]).each do |id, init_proc|
          step = id.title.to_sym
          init_params = trace_build.init_params[id.to_sym]
          layer_object = init_params.nil? ? init_proc.call : init_proc.call(*init_params)
          top.define_singleton_method(id.title.to_sym) { layer_object }
          break top if trace_build.halt_proc&.call(layer_object, id)
        end
        top
      end
    end
  end
end
