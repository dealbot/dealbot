module Dealbot
  module Command
    class AbstractCommand
      class << self
        attr_reader :commands, :parameters

        def command(*commands)
          @commands ||= []
          @commands += commands
        end

        def parameter(*parameters)
          @parameters ||= []
          @parameters += parameters
        end

        def descendants
          @descendants ||= []
        end

        def inherited(descendant)
          descendants << descendant
        end
      end

      attr_reader :parameters

      def execute(*parameters)
        self.class.parameters.length == parameters.length or raise ArgumentError, "Expected #{self.class.parameters.length}, got #{parameters.length}"
        @parameters = Hash[self.class.parameters.zip parameters]
        run
      end

      private

      def activities
        return unless parameters[:deal_id]
        @activities ||= JSON.parse(Pipedrive::Client.get("deals/#{parameters[:deal_id]}/activities").body)['data']
      end

      def enrollments
        return unless parameters[:deal_id]
        @enrollments ||= begin
          str = JSON.parse(Pipedrive::Client.get("deals/#{parameters[:deal_id]}").body)['data'][Pipedrive.cadence_storage_field_id]
          str && str.split(',')
        end
      end

      def deal
        return unless parameters[:deal_id]
        @deal ||= Pipedrive::Deal.new id: parameters[:deal_id]
      end
    end
  end
end