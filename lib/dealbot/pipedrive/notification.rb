module Dealbot
  module Pipedrive
    class Notification < Struct.new(:user_id, :deal_id, :person_id, :organization_id)
      class << self
        def parse(raw)
          current = raw['current']
          notification = new(
            current['user_id'],
            current['id'],
            current['person_id'],
            current['org_id'],
          )
          notification.body = raw
          notification
        end
      end

      attr_accessor :body

      def trigger
        return unless eligible?
        [new_pipeline, new_stage]
      end

      private

      def moved?
        pipeline_changed? || stage_changed?
      end
      alias_method :eligible?, :moved?

      def pipeline_changed?
        old_pipeline != new_pipeline
      end

      def stage_changed?
        old_stage != new_stage
      end

      def current
        body['current']
      end

      def previous
        body['previous']
      end

      def old_pipeline
        previous['pipeline_id']
      end

      def new_pipeline
        current['pipeline_id']
      end

      def old_stage
        previous['stage_id']
      end

      def new_stage
        current['stage_id']
      end
    end
  end
end