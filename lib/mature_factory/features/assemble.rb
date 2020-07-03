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
          receiver.composed_of :flat_structs, :wrap_structs, :nest_structs
          receiver.extend Helpers
          receiver.private_class_method :__mf_assembler_execute_and_trace__
          receiver.private_class_method :__mf_assembler_define_struct_assemble_method__
        end

        def wrap(title, base_class: Class.new, delegate: false, &block)
          log = __mf_assembler_execute_and_trace__(order: :direct, &block)
          wrap_struct(title, base_class: base_class)
          __mf_assembler_define_struct_assemble_method__(title, log, :wrap, delegate)
        end

        def nest(title, base_class: Class.new, delegate: false, &block)
          log = __mf_assembler_execute_and_trace__(order: :reverse, &block)
          nest_struct(title, base_class: base_class)
          __mf_assembler_define_struct_assemble_method__(title, log, :nest, delegate)
        end

        def flat(title, base_class: Class.new, &block)
          log = __mf_assembler_execute_and_trace__(&block)
          flat_struct(title, base_class: base_class)
          __mf_assembler_define_struct_assemble_method__(title, log, :flat, nil)
        end
      end

      def self.included(receiver)
        receiver.extend ClassMethods
      end
    end
  end
end
