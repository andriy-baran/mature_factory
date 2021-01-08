module MatureFactory::Features::Assemble
  class Id < Struct.new(:group, :title)
    def to_s
      to_a.compact.reverse.join('_')
    end

    def to_sym
      to_s.to_sym
    end
  end
end
