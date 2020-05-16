require 'dry/inflector'
require 'mature_factory/dsl'
require 'mature_factory/decoration_helpers'
require 'mature_factory/inheritance_helpers'
require 'mature_factory/module_builder'
require 'mature_factory/version'

module MatureFactory
  class Error < StandardError; end

  @modules = {}

  def self.[](components_name)
    find(components_name) || build(components_name)
  end

  def self.find(module_name)
    @modules[module_name]
  end

  def self.register(module_name, module_instance)
    @modules[module_name] = module_instance
  end

  def self.registered_modules
  	@modules.values
  end

  def self.inflector
  	@inflector ||= Dry::Inflector.new
  end

  def self.build(components_name)
  	ModuleBuilder.call.tap do |mod|
	    mod.components_name = components_name
	    mod.component_name = inflector.singularize(components_name)
	    mod.define_components_registry
	    mod.define_component_adding_method
	    mod.define_component_store_method
	    mod.define_component_activation_method
	    register(components_name, mod)
  	end
  end
end
