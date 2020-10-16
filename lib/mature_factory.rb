require 'dry/inflector'
require 'simple_facade'
require 'mature_factory/dsl'
require 'mature_factory/subclassing_helpers'
require 'mature_factory/inheritance_helpers'
require 'mature_factory/module_builder'
require 'mature_factory/composite'
require 'mature_factory/registry'
require 'mature_factory/features/assemble'
require 'mature_factory/version'

module MatureFactory
  class Error < StandardError; end

  module ClassMethods
    def composed_of(*components_names)
      components_names.each do |components_name|
        include MatureFactory::Composite[components_name]
      end
    end
  end

  def self.included(receiver)
    receiver.extend ClassMethods
  end

  def self.inflector
    @inflector ||= Dry::Inflector.new
  end

  def self.registered_modules
    Composite.registered_modules
  end
end
