module MatureFactory::Features::Assemble::Strategies
  class Transform < Struct.new(:strategy, :title, :object)
    ID_CLASS = MatureFactory::Features::Assemble::Id
    def call
      data = strategy.call.to_a
      data.unshift([nil, title, proc{object}]) unless object.nil?
      intermediate_form = data.transpose
      tobe_assembled = intermediate_form[1..-1]
      keys = intermediate_form[0..1].transpose.map{|g,e| ID_CLASS.new(g,e)}
      tobe_assembled.first.pop
      tobe_assembled.first.unshift(nil)
      tobe_assembled << keys
      tobe_assembled.transpose
    end
  end
end
