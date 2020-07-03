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
          receiver.private_class_method :__mf_assembler_execute_and_trace__
          receiver.private_class_method :__mf_assembler_define_struct_assemble_method__
        end

        def wrap(title, base_class: Class.new, init: -> (klass) { klass.new }, delegate: false, &block)
          log = __mf_assembler_execute_and_trace__(order: :direct, &block)
          wrapped_struct(title, base_class: base_class, init: init)
          __mf_assembler_define_struct_assemble_method__(title, log, :wrapped, delegate)
        end

        def nest(title, base_class: Class.new, init: -> (klass) { klass.new }, delegate: false, &block)
          log = __mf_assembler_execute_and_trace__(order: :reverse, &block)
          nested_struct(title, base_class: base_class, init: init)
          __mf_assembler_define_struct_assemble_method__(title, log, :nested, delegate)
        end

        def flat(title, base_class: Class.new, init: -> (klass) { klass.new }, &block)
          log = __mf_assembler_execute_and_trace__(&block)
          flatten_struct(title, base_class: base_class, init: init)
          __mf_assembler_define_struct_assemble_method__(title, log, :flatten, nil)
        end
      end

      def self.included(receiver)
        receiver.extend ClassMethods
      end
    end
  end
end
