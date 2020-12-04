module MatureFactory::Features::Assemble::Strategies
  class Trace
    class Tracer < Struct.new(:yielder)
      def method_missing(method_name, *attrs, &block)
        yielder << [method_name, attrs.first]
      end
    end

    def initialize(&block)
      @block = block
    end

    def call
      Enumerator.new do |yielder|
        tracer = Tracer.new(yielder)
        tracer.instance_eval(&@block)
      end.lazy
    end
  end
end
