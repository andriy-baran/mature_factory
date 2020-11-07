class Fine; def inspect; '<Fine>'; end; end
class Good; def inspect; '<Good>'; end; end
class Best; def inspect; '<Best>'; end; end
RSpec.describe MatureFactory do
  vars do
    target! do
      Class.new do
        include MatureFactory
        include MatureFactory::Features::Assemble

        composed_of :elements

        wrap :main do
          element :fine, base_class: Fine
          element :good, base_class: Good
          element :best, base_class: Best
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
      res = target.assemble_main_struct do
              on_create { halt! if !object.valid? }
            end
      expect(res.valid?).to eq(false)
      # expect(res).to eq nil
    end
  end
end
