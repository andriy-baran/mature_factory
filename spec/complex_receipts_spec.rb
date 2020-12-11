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
              flat :nine do
                wrap :eleven do
                  part :twelve
                  stage :thirteen
                end
                nest :fourteen do
                  part :fifteen
                  stage :sixteen
                end
              end
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
        twelve_part do
          def t; 't'; end
        end
      end
    end
  end

  it 'returns resulted objects composition' do
    res = target.build_main.call
    expect(res.a).to eq 1
    expect(res.one.b).to eq 1
    expect(res.two.c).to eq 1
    expect(res.two.four.five.nine.eleven.thirteen.twelve.t).to eq 't'
    expect(res.zero).to be_an_instance_of(target.zero_input_class)
    expect(res.one).to be_an_instance_of(target.one_wrapped_struct_class)
    expect(res.one.eight.seven).to be_an_instance_of(target.seven_stage_class)
    expect(res.one.eight.seven).to be_an_instance_of(target.seven_stage_class)
    expect(res.one.eight.seven.three).to be_an_instance_of(target.three_part_class)
    expect(res.two).to be_an_instance_of(target.two_nested_struct_class)
    expect(res.two.four).to be_an_instance_of(target.four_part_class)
    expect(res.two.four.five).to be_an_instance_of(target.five_flatten_struct_class)
    expect(res.two.four.five.six).to be_an_instance_of(target.six_part_class)
    expect(res.two.four.five.nine).to be_an_instance_of(target.nine_flatten_struct_class)
    expect(res.two.four.five.nine.eleven).to be_an_instance_of(target.eleven_wrapped_struct_class)
    expect(res.two.four.five.nine.eleven.thirteen.twelve).to be_an_instance_of(target.twelve_part_class)
    expect(res.two.four.five.nine.eleven.thirteen).to be_an_instance_of(target.thirteen_stage_class)
    expect(res.two.four.five.nine.fourteen).to be_an_instance_of(target.fourteen_nested_struct_class)
    expect(res.two.four.five.nine.fourteen.fifteen).to be_an_instance_of(target.fifteen_part_class)
    expect(res.two.four.five.nine.fourteen.fifteen.sixteen).to be_an_instance_of(target.sixteen_stage_class)
    expect(res.ten).to be_an_instance_of(target.ten_output_class)
  end
end
