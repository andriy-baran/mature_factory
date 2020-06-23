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
          receiver.extend Helpers
          receiver.private_class_method :__mf_assembler_new_instance__
          receiver.private_class_method :__mf_assembler_execute_and_trace__
          receiver.private_class_method :__mf_assembler_define_flat_struct_assemble_method__
          receiver.private_class_method :__mf_assembler_define_layered_struct_assemble_method__
        end

        def wrap(title, break_if: nil, delegate: false, &block)
          log = __mf_assembler_execute_and_trace__(order: :direct, &block)
          __mf_assembler_define_layered_struct_assemble_method__(title, log, break_if, delegate)
        end

        def nest(title, break_if: nil, delegate: false, &block)
          log = __mf_assembler_execute_and_trace__(order: :reverse, &block)
          __mf_assembler_define_layered_struct_assemble_method__(title, log, break_if, delegate)
        end

        def flat(title, break_if: nil, &block)
          log = __mf_assembler_execute_and_trace__(&block)
          __mf_assembler_define_flat_struct_assemble_method__(title, log, break_if)
        end
      end

      def self.included(receiver)
        receiver.extend ClassMethods
      end
    end
  end
end
