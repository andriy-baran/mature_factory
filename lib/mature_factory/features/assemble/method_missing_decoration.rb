module MatureFactory
  module Features
    module Assemble
      module MethodMissingDecoration
        def method_missing(name, *attrs, &block)
          if methods.grep(:__mf_predecessor__).first
            public_send(__mf_predecessor__).public_send(name, *attrs, &block)
          else
            super
          end
        end

        def respond_to_missing?(method_name, _include_private = false)
          predecessors, obj = [], self
          while obj.methods.grep(:__mf_predecessor__).first
            predecessor = obj.public_send(obj.__mf_predecessor__)
            predecessors << obj = predecessor
          end
          predecessors.any? { |obj| obj.respond_to?(method_name) }
        end
      end
    end
  end
end
