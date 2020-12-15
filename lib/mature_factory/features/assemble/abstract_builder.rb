require 'mature_factory/features/assemble/strategies/execute'
require 'mature_factory/features/assemble/strategies/enumerate'
require 'mature_factory/features/assemble/strategies/trace'
require 'mature_factory/features/assemble/strategies/reverse'
require 'mature_factory/features/assemble/strategies/prepare'
require 'mature_factory/features/assemble/strategies/transform'
require 'mature_factory/features/assemble/strategies/inject'
require 'mature_factory/features/assemble/strategies/init'
require 'mature_factory/features/assemble/strategies/link'
require 'mature_factory/features/assemble/strategies/mount'

module MatureFactory::Features::Assemble
  class AbstractBuilder < Struct.new(:factory)
    MMD_MODULE = MatureFactory::Features::Assemble::MethodMissingDecoration
    PROXY_CLASS = MatureFactory::Features::Assemble::Proxy

    def self.link_with_delegation(target, object, accessor, delegate)
      target.define_singleton_method(:__mf_predecessor__) { accessor }
      target.define_singleton_method(accessor) { object }
      target.extend(MMD_MODULE) if delegate
    end

    def nest(name, delegate, &block)
      factory.class_eval(&block)
      factory.define_singleton_method(:"build_#{name}") do |title = nil, object = nil, &on_create|
        raise(ArgumentError, 'Both arguments required') if title.nil? ^ object.nil?
        trace = Strategies::Trace.new(&block)
        reverse = Strategies::Reverse.new(trace)
        prepare = Strategies::Prepare.new(reverse, self)
        pipe = Strategies::Transform.new(prepare, title, object).call
        list = pipe.map(&:last).map(&:to_sym)
        inject = Strategies::Inject.new(list, &on_create)
        init = Strategies::Init.new(inject, pipe)
        link = Strategies::Link.new(init, delegate)
        top = public_send(:"new_#{name}_nested_struct_instance")
        enumerate = Strategies::Enumerate.new(link, top, delegate)
        PROXY_CLASS.new(enumerate)
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
        inject = Strategies::Inject.new(list, &on_create)
        init = Strategies::Init.new(inject, pipe)
        link = Strategies::Link.new(init, delegate)
        top = public_send(:"new_#{name}_wrapped_struct_instance")
        enumerate = Strategies::Enumerate.new(link, top, delegate)
        PROXY_CLASS.new(enumerate)
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
        inject = Strategies::Inject.new(ids.map(&:to_sym), &on_create)
        top = public_send(:"new_#{name}_flatten_struct_instance")
        mount = Strategies::Mount.new(inject, ids.zip(list[-1]), top, title)
        enumerate = Strategies::Execute.new(mount, top)
        PROXY_CLASS.new(enumerate)
      end
    end
  end
end
