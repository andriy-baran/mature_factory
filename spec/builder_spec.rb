require 'mature_factory/features/assemble/abstract_builder'


class Fine; def inspect; '<Fine>'; end; end
class Good
  attr_reader :one, :two
  def initialize(one, two:)
    @one = one
    @two = two
  end
  def inspect; '<Good>'; end;
end
class Best; def inspect; '<Best>'; end; end

RSpec.describe MatureFactory::Features::Assemble::AbstractBuilder do
  xdescribe '.build' do
    let(:factory) { Class.new{include MatureFactory; extend MatureFactory::Features::Assemble::Helpers; composed_of :elements} }
    let(:builder) { MatureFactory::Features::Assemble::AbstractBuilder.new(factory) }

    it 'build nest with break' do
      builder.nest(:line, false) do
        element :fine, base_class: Fine
        element :good, base_class: Good, init: -> (k, a, kw) { k.new(a, kw) }
        element :best, base_class: Best
      end
      factory.class_eval do
        good_element do
          def valid?; false; end
        end

        fine_element do
          def valid?; true; end
        end
      end
      result =
        factory.build_line do
          good_element Object.new, two: 2
          halt_if { |object, _id| !object.valid? }
        end
      expect(result).to_not respond_to(:good)
      expect(result).to be_a(Good)
      expect(result.one).to be_an_instance_of(Object)
      expect(result.two).to eq(2)
      expect(result.best).to be_an_instance_of(Best)
    end

    it 'build nest' do
      builder.nest(:line, true) do
        element :fine, base_class: Fine
        element :good, base_class: Good, init: -> (k, a, kw) { k.new(a, kw) }
        element :best, base_class: Best
      end
      result =
        factory.build_line do
          good_element Object.new, two: 2
        end
      expect(result).to be_an_instance_of(Fine)
      expect(result).to respond_to(:one)
      expect(result.good).to be_an_instance_of(Good)
      expect(result.good.one).to be_an_instance_of(Object)
      expect(result.good.two).to eq(2)
      expect(result.good.best).to be_an_instance_of(Best)
    end
  end
end
