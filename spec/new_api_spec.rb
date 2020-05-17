RSpec.describe MatureFactory do
  vars do
    target! do
      Class.new do
        include MatureFactory

        composed_of :inputs, :outputs
      end
    end
  end

  it { expect(target).to respond_to(:inputs) }
  it { expect(target).to respond_to(:outputs) }
end
