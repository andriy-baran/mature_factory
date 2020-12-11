require 'mature_factory/features/assemble/method_missing_decoration'
require 'mature_factory/features/assemble/id'
require 'mature_factory/features/assemble/proxy'
require 'mature_factory/features/assemble/abstract_builder'
require 'mature_factory/features/assemble/helpers'

module MatureFactory
  module Features
    module Assemble
      module ClassMethods
        class << self
          attr_accessor :__mf_assembler_name__
        end

        def self.included(receiver)
          receiver.extend self
        end

        def self.extended(receiver)
          receiver.composed_of :flatten_structs, :wrapped_structs, :nested_structs
          receiver.extend Helpers
        end

        def wrap(title, base_class: Class.new, init: nil, delegate: false, &block)
          wrapped_struct(title, base_class: base_class, init: init)
          AbstractBuilder.new(self).wrap(title, delegate, &block)
        end

        def nest(title, base_class: Class.new, init: nil, delegate: false, &block)
          nested_struct(title, base_class: base_class, init: init)
          AbstractBuilder.new(self).nest(title, delegate, &block)
        end

        def flat(title, base_class: Class.new, init: nil, &block)
          flatten_struct(title, base_class: base_class, init: init)
          AbstractBuilder.new(self).flat(title, &block)
        end
      end

      def self.included(receiver)
        receiver.extend ClassMethods
      end
    end
  end
end
