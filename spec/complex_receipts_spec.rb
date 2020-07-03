RSpec.describe MatureFactory do
  vars do
    target! do
      Class.new do
        include MatureFactory
        include MatureFactory::Features::Assemble

        composed_of :inputs, :outputs, :stages, :parts

        flat :main do
          input :zero
          wrap :one do
            part :three
            stage :seven
            stage :eight
          end
          nest :two do
            part :four
            flat :five do
              part :six
            end
          end
          output :ten
        end
      end
    end
  end

  it 'returns resulted objects composition' do
    res = target.assemble_main_struct
    expect(res.zero).to be_an_instance_of(target.zero_input_class)
    expect(res.one).to be_a(Object)
    expect(res.one.eight.seven).to be_an_instance_of(target.seven_stage_class)
    expect(res.one.eight.seven).to be_an_instance_of(target.seven_stage_class)
    expect(res.one.eight.seven.three).to be_an_instance_of(target.three_part_class)
    expect(res.two).to be_a(Object)
    expect(res.two.four).to be_an_instance_of(target.four_part_class)
    expect(res.two.four.five).to be_an_instance_of(target.five_flat_struct_class)
    expect(res.two.four.five.six).to be_an_instance_of(target.six_part_class)
    expect(res.ten).to be_an_instance_of(target.ten_output_class)
  end
end
