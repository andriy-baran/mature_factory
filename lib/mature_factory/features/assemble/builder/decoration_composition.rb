module MatureFactory
  module Features
    module Assemble
      module Builder
        class DecorationComposition < Base
          def observer_class
            MatureFactory::Features::Assemble::WrappingObserver
          end

          def local_observer
            @local_observer ||= observer_class.new(previous_step, current_object, delegate)
          end
        end
      end
    end
  end
end
