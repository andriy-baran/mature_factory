module MatureFactory
  module Features
    module Assemble
      class WrappingObserver
        MMD_MODULE = MatureFactory::Features::Assemble::MethodMissingDecoration

        attr_reader :current_object, :previous_step

        def initialize(previous_step = nil, current_object = nil, delegate)
          @previous_step = previous_step
          @current_object = current_object
          @delegate = delegate
        end

        def on_new_object(accessor, object)
          @current_object = wrap(@current_object, object, @previous_step, @delegate)
          @previous_step = accessor
        end

        def wrap(current_object, wrapper_object, accessor, delegate)
          return wrapper_object if accessor.nil? || current_object.nil?
          wrapper_object.singleton_class.class_eval do
            attr_accessor :__mf_assembler_predecessor__
          end
          wrapper_object.__mf_assembler_predecessor__ = accessor
          wrapper_object.extend(MMD_MODULE) if delegate
          wrapper_object.singleton_class.class_eval do
            attr_accessor wrapper_object.__mf_assembler_predecessor__
          end
          wrapper_object.public_send(:"#{wrapper_object.__mf_assembler_predecessor__}=", current_object)
          wrapper_object
        end
      end
    end
  end
end
