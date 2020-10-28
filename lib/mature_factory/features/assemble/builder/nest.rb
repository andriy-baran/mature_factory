module MatureFactory
  module Features
    module Assemble
      module Builder
        class Nest < Base
          def call(&on_create_proc)
            build_components(&on_create_proc)
            link_and_delegate
          end

          private

          def link_and_delegate
            obj = local_observer.link_members
            while delegate && (obj.predecessor rescue false)
              obj = obj.public_send(obj.predecessor).extend(MMD_MODULE)
            end
            local_observer.current_object
          end
        end
      end
    end
  end
end
