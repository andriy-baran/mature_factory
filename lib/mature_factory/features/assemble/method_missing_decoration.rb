module MatureFactory
  module Features
    module Assemble
      module MethodMissingDecoration
        def method_missing(name, *attrs, &block)
          if methods.grep(:predecessor).first
            public_send(predecessor).public_send(name, *attrs, &block)
          else
            super
          end
        end

        def respond_to_missing?(method_name, _include_private = false)
          predecessors, obj = [], self
          while obj.methods.grep(:predecessor).first
            predecessor = obj.public_send(obj.predecessor)
            predecessors << obj = predecessor
          end
          predecessors.any? { |obj| obj.respond_to?(method_name) }
        end
      end
    end
  end
end
