module MatureFactory::Features::Assemble::Strategies
  class TraceBuild
    class Tracer
      attr_reader :__halt_proc__, :__result__

      def initialize(list)
        @list = list
        @__halt_proc__ = nil
        @__result__ = {}
      end

      def method_missing(method_name, *attrs, &block)
        if method_name == :halt_if && block_given?
          @__halt_proc__ = block
        elsif @list.include?(method_name)
          @__result__[method_name] = attrs
        else
          super
        end
      end
    end

    attr_reader :halt_proc, :init_params

    def initialize(list, &block)
      @block = block
      @list = list
    end

    def call
      tracer = Tracer.new(@list)
      tracer.instance_eval(&@block) if !@block.nil?
      @halt_proc = tracer.__halt_proc__
      @init_params = tracer.__result__
    end
  end
end
