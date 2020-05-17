require 'dry/inflector'
require 'mature_factory/dsl'
require 'mature_factory/decoration_helpers'
require 'mature_factory/inheritance_helpers'
require 'mature_factory/module_builder'
require 'mature_factory/composite'
require 'mature_factory/registry'
require 'mature_factory/dsl'
require 'mature_factory/version'

module MatureFactory
  class Error < StandardError; end

  def self.inflector
    @inflector ||= Dry::Inflector.new
  end

  def self.registered_modules
    Composite.registered_modules
  end
end
