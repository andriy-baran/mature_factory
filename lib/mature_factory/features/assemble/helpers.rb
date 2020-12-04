module MatureFactory
  module Features
    module Assemble
      module Helpers
        def __mf_assembler_new_instance__(component_name, step, *attrs)
          mod = included_modules.detect {|m| m.respond_to?(:component_name) && m.component_name == component_name.to_s }
          if %i(flat wrap nest).include?(component_name)
            method(:"build_#{step}")
          elsif !mod.nil?
            init_method = public_send(mod.__mf_component_class_reader__(step)).method(:__mf_init__)
            if 1 < init_method.arity
              create_method = method(mod.__mf_new_instance_method_name__(step))
              create_method.curry(create_method.arity.abs)
            else
              method(mod.__mf_new_instance_method_name__(step))
            end
          end
        end
      end
    end
  end
end
