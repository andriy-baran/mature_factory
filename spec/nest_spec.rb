RSpec.describe MatureFactory do
  vars do
    target! do
      Class.new do
        include MatureFactory
        include MatureFactory::Features::Assemble

        composed_of :inputs, :outputs, :steps

        nest :main, delegate: true do
          input :zero
          step :four
          step :one
          step :two
          step :three
          output :ten
        end

        zero_input do
          def a; 'a'; end
        end
        four_step do
          def b; 'b'; end
        end
        one_step do
          def c; 'c'; end
        end
        two_step do
          def d; 'd'; end
        end
        three_step do
          def e; 'e'; end
        end
        ten_output do
          def f; 'f'; end
        end
      end
    end
  end

  it { expect(target).to respond_to(:mf_inputs) }
  it { expect(target).to respond_to(:mf_outputs) }
  it { expect(target).to respond_to(:mf_steps) }
  it { expect(target).to respond_to(:one_step_class) }
  it { expect(target).to respond_to(:two_step_class) }
  it { expect(target).to respond_to(:three_step_class) }
  it { expect(target).to respond_to(:four_step_class) }
  it { expect(target).to respond_to(:zero_input_class) }
  it { expect(target).to respond_to(:ten_output_class) }
  it { expect(target).to respond_to(:assemble_main_struct) }

  describe '.assemble_*_struct' do
    it 'returns resulted objects composition' do
      res = target.assemble_main_struct
      expect(res).to respond_to(:zero)
      expect(res).to respond_to(:three)
      expect(res).to respond_to(:four)
      expect(res).to respond_to(:one)
      expect(res).to respond_to(:two)
      expect(res).to respond_to(:ten)
      expect(res.zero).to be_an_instance_of(target.zero_input_class)
      expect(res.ten).to be_an_instance_of(target.ten_output_class)
      expect(res.three).to be_an_instance_of(target.three_step_class)
      expect(res.four).to be_an_instance_of(target.four_step_class)
      expect(res.one).to be_an_instance_of(target.one_step_class)
      expect(res.two).to be_an_instance_of(target.two_step_class)
      expect(res.four).to_not respond_to(:zero)
      expect(res.four).to_not respond_to(:four)
      expect(res.four).to respond_to(:two)
      expect(res.four).to respond_to(:three)
      expect(res.four).to respond_to(:one)
      expect(res.four).to respond_to(:ten)
      expect(res.four.one).to_not respond_to(:zero)
      expect(res.four.one).to_not respond_to(:four)
      expect(res.four.one).to_not respond_to(:one)
      expect(res.four.one).to respond_to(:ten)
      expect(res.four.one).to respond_to(:three)
      expect(res.four.one).to respond_to(:two)
      expect(res.four.one.two).to_not respond_to(:zero)
      expect(res.four.one.two).to_not respond_to(:two)
      expect(res.four.one.two).to_not respond_to(:four)
      expect(res.four.one.two).to_not respond_to(:one)
      expect(res.four.one.two).to respond_to(:three)
      expect(res.four.one.two).to respond_to(:ten)
      expect(res.four.one.two.three).to_not respond_to(:zero)
      expect(res.four.one.two.three).to_not respond_to(:two)
      expect(res.four.one.two.three).to_not respond_to(:four)
      expect(res.four.one.two.three).to_not respond_to(:one)
      expect(res.four.one.two.three).to_not respond_to(:three)
      expect(res.four.one.two.three).to respond_to(:ten)
      expect(res.four.one.two.three.ten).to_not respond_to(:ten)
      expect(res.four.one.two.three.ten).to_not respond_to(:three)
      expect(res.four.one.two.three.ten).to_not respond_to(:two)
      expect(res.four.one.two.three.ten).to_not respond_to(:four)
      expect(res.four.one.two.three.ten).to_not respond_to(:one)
      expect(res.four.one.two.three.ten).to_not respond_to(:zero)
    end

    it 'aggregates all data and methods in the pipe' do
      res = target.assemble_main_struct
      expect(res.a).to eq 'a'
      expect(res.b).to eq 'b'
      expect(res.c).to eq 'c'
      expect(res.d).to eq 'd'
      expect(res.e).to eq 'e'
      expect(res.f).to eq 'f'
    end

    context 'when break proc and after creation proc provided' do
      it 'returns enumerator with created objects' do
        res = target.assemble_main_struct break_if: ->(t,o) { t == :one } do |t, o|
          o.singleton_class.send(:define_method, :g) { 'g' } if t == :two
        end
        expect(res).to_not respond_to(:zero)
        expect(res).to_not respond_to(:four)
        expect(res.g).to eq 'g'
      end
    end
  end

  context 'double inheritance' do
    vars do
      child do
        Class.new(target) do
          ten_output do
            def f; 'g'; end
          end
        end
      end
      child_of_child do
        Class.new(child)
      end
    end

    describe '.assemble_*_struct' do
      it 'returns resulted objects composition' do
        obj = OpenStruct.new(h: 'h')
        res = child_of_child.assemble_main_struct(:init, obj)

        expect(res).to respond_to(:zero)
        expect(res).to respond_to(:three)
        expect(res).to respond_to(:four)
        expect(res).to respond_to(:one)
        expect(res).to respond_to(:two)
        expect(res).to respond_to(:ten)
        expect(res.zero).to be_an_instance_of(target.zero_input_class)
        expect(res.ten).to be_an_instance_of(child.ten_output_class)
        expect(res.three).to be_an_instance_of(target.three_step_class)
        expect(res.four).to be_an_instance_of(target.four_step_class)
        expect(res.one).to be_an_instance_of(target.one_step_class)
        expect(res.two).to be_an_instance_of(target.two_step_class)
        expect(res.init).to eq(obj)
        expect(res.four).to_not respond_to(:zero)
        expect(res.four).to_not respond_to(:four)
        expect(res.four).to respond_to(:two)
        expect(res.four).to respond_to(:three)
        expect(res.four).to respond_to(:one)
        expect(res.four).to respond_to(:ten)
        expect(res.four.one).to_not respond_to(:zero)
        expect(res.four.one).to_not respond_to(:four)
        expect(res.four.one).to_not respond_to(:one)
        expect(res.four.one).to respond_to(:ten)
        expect(res.four.one).to respond_to(:three)
        expect(res.four.one).to respond_to(:two)
        expect(res.four.one.two).to_not respond_to(:zero)
        expect(res.four.one.two).to_not respond_to(:two)
        expect(res.four.one.two).to_not respond_to(:four)
        expect(res.four.one.two).to_not respond_to(:one)
        expect(res.four.one.two).to respond_to(:three)
        expect(res.four.one.two).to respond_to(:ten)
        expect(res.four.one.two.three).to_not respond_to(:zero)
        expect(res.four.one.two.three).to_not respond_to(:two)
        expect(res.four.one.two.three).to_not respond_to(:four)
        expect(res.four.one.two.three).to_not respond_to(:one)
        expect(res.four.one.two.three).to_not respond_to(:three)
        expect(res.four.one.two.three).to respond_to(:ten)
        expect(res.four.one.two.three.ten).to_not respond_to(:ten)
        expect(res.four.one.two.three.ten).to_not respond_to(:three)
        expect(res.four.one.two.three.ten).to_not respond_to(:two)
        expect(res.four.one.two.three.ten).to_not respond_to(:four)
        expect(res.four.one.two.three.ten).to_not respond_to(:one)
        expect(res.four.one.two.three.ten).to_not respond_to(:zero)
      end

      it 'aggregates all data and methods in the pipe' do
        obj = OpenStruct.new(h: 'h')
        res = child_of_child.assemble_main_struct(:init, obj)

        expect(res.a).to eq 'a'
        expect(res.b).to eq 'b'
        expect(res.c).to eq 'c'
        expect(res.d).to eq 'd'
        expect(res.e).to eq 'e'
        expect(res.f).to eq 'g'
        expect(res.h).to eq 'h'
      end

      context 'when break proc and after creation proc provided' do
        it 'returns enumerator with created objects' do
          res = child_of_child.assemble_main_struct break_if: ->(t,o) { t == :one } do |t, o|
            o.singleton_class.send(:define_method, :g) { 'g' } if t == :two
          end
          expect(res).to_not respond_to(:zero)
          expect(res).to_not respond_to(:four)
          expect(res.g).to eq 'g'
        end
      end
    end
  end
end
