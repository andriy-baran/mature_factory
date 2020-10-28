RSpec.describe MatureFactory do
  vars do
    target! do
      Class.new do
        include MatureFactory
        include MatureFactory::Features::Assemble

        composed_of :elements

        wrap :main do
          element :fine
          element :good
        end

        good_element do
          def valid?; false; end
        end

        fine_element do
          def valid?; true; end
        end
      end
    end
  end

  describe 'wrap' do
    it 'properly organize order of methods calling' do
      res = target.assemble_main_struct
      expect(res.valid?).to eq(false)
    end
  end
end
