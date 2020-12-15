module MatureFactory::Features::Assemble::Strategies
  class Inject
    class Tracer
      attr_reader :__result__

      def initialize(list)
        @list = list
        @__result__ = {}
      end

      def method_missing(method_name, *attrs, &block)
        if @list.include?(method_name)
          @__result__[method_name] = attrs
        else
          super
        end
      end
    end

    def initialize(list, &block)
      @block = block
      @list = list
    end

    def call
      tracer = Tracer.new(@list)
      tracer.instance_eval(&@block) if !@block.nil?
      tracer.__result__
    end
  end
end
