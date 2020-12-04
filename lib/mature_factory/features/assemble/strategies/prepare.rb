module MatureFactory::Features::Assemble::Strategies
  class Prepare < Struct.new(:strategy, :factory)
    def call
      strategy.call.map do |group, title|
        [group, title, factory.__mf_assembler_new_instance__(group, title)]
      end
    end
  end
end
