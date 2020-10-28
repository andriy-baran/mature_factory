module MatureFactory
  module Features
    module Assemble
      module Builder
        class Flat < Base
          def call(&on_create_proc)
            build_components(&on_create_proc)
            local_observer.current_object
          end
        end
      end
    end
  end
end
