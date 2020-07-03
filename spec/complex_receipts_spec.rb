RSpec.describe MatureFactory do
  vars do
    target! do
      Class.new do
        include MatureFactory
        include MatureFactory::Features::Assemble

        composed_of :inputs, :outputs, :stages, :parts

        flat :main, init: ->(k, a = 1){k.new(a: a)} do
          input :zero
          wrap :one, init: ->(k, a = 1){k.new(b: a)} do
            part :three
            stage :seven
            stage :eight
          end
          nest :two, init: ->(k, a = 1){k.new(c: a)} do
            part :four
            flat :five do
              part :six
            end
          end
          output :ten
        end
        main_flatten_struct do
          attr_reader :a
          def initialize(a:)
            @a = a
          end
        end
        one_wrapped_struct do
          attr_reader :b
          def initialize(b:)
            @b = b
          end
        end
        two_nested_struct do
          attr_reader :c
          def initialize(c:)
            @c = c
          end
        end
      end
    end
  end

  it 'returns resulted objects composition' do
    res = target.assemble_main_struct
    expect(res.a).to eq 1
    expect(res.one.b).to eq 1
    expect(res.two.c).to eq 1
    expect(res.zero).to be_an_instance_of(target.zero_input_class)
    expect(res.one).to be_an_instance_of(target.one_wrapped_struct_class)
    expect(res.one.eight.seven).to be_an_instance_of(target.seven_stage_class)
    expect(res.one.eight.seven).to be_an_instance_of(target.seven_stage_class)
    expect(res.one.eight.seven.three).to be_an_instance_of(target.three_part_class)
    expect(res.two).to be_an_instance_of(target.two_nested_struct_class)
    expect(res.two.four).to be_an_instance_of(target.four_part_class)
    expect(res.two.four.five).to be_an_instance_of(target.five_flatten_struct_class)
    expect(res.two.four.five.six).to be_an_instance_of(target.six_part_class)
    expect(res.ten).to be_an_instance_of(target.ten_output_class)
  end
end
