class Fine; def inspect; '<Fine>'; end; end
class Good2; def inspect; '<Good>'; end; end
class Best; def inspect; '<Best>'; end; end
RSpec.describe MatureFactory do
  vars do
    target! do
      Class.new do
        include MatureFactory
        include MatureFactory::Features::Assemble

        produces :elements

        wrap :main, delegate: true do
          element :fine, base_class: Fine
          element :good, base_class: Good2
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
      res = target.build_main.call {|o, i| p i; throw :halt if !o.valid? }
      # res = target.build_main.call
      expect(res.valid?).to eq(false)
    end
  end
end
