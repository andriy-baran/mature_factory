CustomType = Class.new(Struct.new(:id))
RSpec.describe MatureFactory do
  vars do
    target! do
      Class.new do
        include MatureFactory

        produces :inputs, :outputs do
          parts base_class: CustomType, init: -> (k,id) { k.new(id) }
        end

        input :one
        input :two
        part :one
      end
    end
  end

  it { expect(target).to respond_to(:mf_inputs) }
  it { expect(target).to respond_to(:mf_outputs) }
  it { expect(target).to respond_to(:mf_parts) }

  it 'has inputs list' do
    expect(target.mf_inputs).to match({one: be_a(Class), two: be_a(Class)})
  end

  it 'has outputs list' do
    expect(target.mf_outputs).to eq({})
  end

  it 'sets default base_class for a group' do
    expect(target.one_part_class).to eq CustomType
  end

  it 'sets default init for a group' do
    expect(target.new_one_part_instance(3).id).to eq 3
  end
end
