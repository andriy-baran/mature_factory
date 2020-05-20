RSpec.describe MatureFactory do
  vars do
    target! do
      Class.new do
        include MatureFactory

        composed_of :inputs, :outputs

        input :one
        input :two
      end
    end
  end

  it { expect(target).to respond_to(:mf_inputs) }
  it { expect(target).to respond_to(:mf_outputs) }

  it 'has inputs list' do
    expect(target.mf_inputs).to match({one: be_a(Class), two: be_a(Class)})
  end

  it 'has outputs list' do
    expect(target.mf_outputs).to eq({})
  end
end
