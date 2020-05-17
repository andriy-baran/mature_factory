RSpec.describe MatureFactory do
  vars do
    target! do
      Class.new do
        include MatureFactory
        include MatureFactory::Features::Assemble

        composed_of :inputs, :outputs, :stages

        flat :main do
          input :zero
          stage :four
          stage :one
          stage :two
          stage :three
          output :ten
        end

        zero_input do
          def a; 'a'; end
        end
        four_stage do
          def b; 'b'; end
        end
        one_stage do
          def c; 'c'; end
        end
        two_stage do
          def d; 'd'; end
        end
        three_stage do
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
  it { expect(target).to respond_to(:mf_stages) }
  it { expect(target).to respond_to(:one_stage_class) }
  it { expect(target).to respond_to(:two_stage_class) }
  it { expect(target).to respond_to(:three_stage_class) }
  it { expect(target).to respond_to(:four_stage_class) }
  it { expect(target).to respond_to(:zero_input_class) }
  it { expect(target).to respond_to(:ten_output_class) }
  it { expect(target).to respond_to(:assemble_main_struct) }

  describe '.assemble_*_struct' do
    it 'returns resulted objects composition' do
      res = target.assemble_main_struct
      expect(res).to respond_to(:ten)
      expect(res).to respond_to(:three)
      expect(res).to respond_to(:four)
      expect(res).to respond_to(:one)
      expect(res).to respond_to(:zero)
      expect(res).to respond_to(:two)
      expect(res.ten).to be_an_instance_of(target.ten_output_class)
      expect(res.three).to be_an_instance_of(target.three_stage_class)
      expect(res.four).to be_an_instance_of(target.four_stage_class)
      expect(res.one).to be_an_instance_of(target.one_stage_class)
      expect(res.zero).to be_an_instance_of(target.zero_input_class)
      expect(res.two).to be_an_instance_of(target.two_stage_class)
    end

    it 'patches original classes' do
      res = target.assemble_main_struct
      expect(res.zero.a).to eq 'a'
      expect(res.four.b).to eq 'b'
      expect(res.one.c).to eq 'c'
      expect(res.two.d).to eq 'd'
      expect(res.three.e).to eq 'e'
      expect(res.ten.f).to eq 'f'
    end

    context 'when break proc and after creation proc provided' do
      it 'returns enumerator with created objects' do
        res = target.assemble_main_struct break_if: ->(t,o) { t == :one } do |t, o|
          o.singleton_class.send(:define_method, :g) { 'g' } if t == :four
        end
        expect(res.two).to be_nil
        expect(res.three).to be_nil
        expect(res.ten).to be_nil
        expect(res.one).to be_nil
        expect(res.four.g).to eq 'g'
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
        expect(res).to respond_to(:init)
        expect(res).to respond_to(:ten)
        expect(res).to respond_to(:three)
        expect(res).to respond_to(:four)
        expect(res).to respond_to(:one)
        expect(res).to respond_to(:zero)
        expect(res).to respond_to(:two)
        expect(res.init).to eq(obj)
        expect(res.ten).to be_an_instance_of(child.ten_output_class)
        expect(res.three).to be_an_instance_of(target.three_stage_class)
        expect(res.four).to be_an_instance_of(target.four_stage_class)
        expect(res.one).to be_an_instance_of(target.one_stage_class)
        expect(res.zero).to be_an_instance_of(target.zero_input_class)
        expect(res.two).to be_an_instance_of(target.two_stage_class)
      end

      it 'patches original classes' do
        obj = OpenStruct.new(h: 'h')
        res = child_of_child.assemble_main_struct(:init, obj)

        expect(res.zero.a).to eq 'a'
        expect(res.four.b).to eq 'b'
        expect(res.one.c).to eq 'c'
        expect(res.two.d).to eq 'd'
        expect(res.three.e).to eq 'e'
        expect(res.ten.f).to eq 'g'
        expect(res.init.h).to eq 'h'
      end

      context 'when break proc and after creation proc provided' do
        it 'returns enumerator with created objects' do
          res = child_of_child.assemble_main_struct break_if: ->(t,o) { t == :one } do |t, o|
            o.singleton_class.send(:define_method, :g) { 'g' } if t == :four
          end
          expect(res.two).to be_nil
          expect(res.three).to be_nil
          expect(res.ten).to be_nil
          expect(res.one).to be_nil
          expect(res.four.g).to eq 'g'
        end
      end
    end
  end
end
