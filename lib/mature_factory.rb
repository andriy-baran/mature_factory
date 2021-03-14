require 'dry/inflector'
require 'simple_facade'
require 'mature_factory/dsl'
require 'mature_factory/group_definition'
require 'mature_factory/subclassing_helpers'
require 'mature_factory/inheritance_helpers'
require 'mature_factory/module_builder'
require 'mature_factory/prototype'
require 'mature_factory/registry'
require 'mature_factory/features/assemble'
require 'mature_factory/version'

module MatureFactory
  class Error < StandardError; end

  module ClassMethods
    def produces(*components_names, &block)
      components_names.each do |components_name|
        include MatureFactory::Prototype[components_name]
      end
      groups = GroupDefinition.new
      groups.instance_eval(&block) if block_given?
      groups.definitions.each do |components_name, attrs|
        include MatureFactory::Prototype[components_name, **attrs]
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
    Prototype.registered_modules
  end
end
