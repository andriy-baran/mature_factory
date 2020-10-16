RSpec.describe MatureFactory do
  vars do
    target! do
      Class.new do
        include MatureFactory
        include MatureFactory::Features::Assemble

        composed_of :inputs, :outputs, :stages

        flat :main, base_class: Class.new {def to_s; 'main'; end} do
          input :zero, init: -> (klass, x = 1, y = 2) { klass.new(x, y) }
          stage :four
          stage :one
          stage :two
          stage :three
          output :ten
        end

        zero_input do
          attr_reader :x, :y
          def initialize(x,y)
            @x = x
            @y = y
          end
          def a; 'a'; end
        end
      end
    end
  end

  describe 'factory object' do
    context 'when assembling objects' do
      it 'returns factory object for single instance' do
        res = target.assemble_main_struct do |c|
                c.stage_four do |o|
                  def o.g; 'g'; end
                end
                c.input_zero(3, 4)
                c.halt! if c.stage_one?
              end
        expect(res.zero.x).to eq 3
        expect(res.zero.y).to eq 4
        expect(res.four.g).to eq 'g'
      end
    end
  end
end
