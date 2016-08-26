module Dealbot
  module Command
    class Abort < AbstractCommand
      command :abort
      parameter :deal_id
      parameter :trigger_and_or_cadence

      private

      def run
        if delete_activities
          msg = "Aborted [#{parameters[:trigger_and_or_cadence]}]"
          deal.add_note content: "[Dealbot] #{msg}"
        else
          msg = "No related activities found"
        end
        unregister_enrollments
        msg
      end

      def delete_activities
        activities or return false
        changed = false
        activities.each do |activity|
          Dealbot.log 'abort', parameters[:deal_id], "  Evaluating activity: #{activity['subject']}"
          if activity['subject'] =~ /\[[a-zA-Z0-9\-_\/]*#{parameters[:trigger_and_or_cadence]}[a-zA-Z0-9\-_\/]*\]$/
            Dealbot.log 'abort', parameters[:deal_id], "    Found match"
            if activity['done']
              Dealbot.log 'abort', parameters[:deal_id], "      Already done, leaving for posterity"
            else
              Dealbot.log 'abort', parameters[:deal_id], "      Deleting"
              Pipedrive::Client.delete "activities/#{activity.fetch('id')}"
              changed = true
            end
          else
            Dealbot.log 'abort', parameters[:deal_id], "    Unrelated activity, skipping"
          end
        end
        changed
      end

      def unregister_enrollments
        Dealbot.log 'abort', parameters[:deal_id], "  Removing enrollments"
        Pipedrive::Client.put "deals/#{parameters[:deal_id]}", Pipedrive.cadence_storage_field_id => new_enrollments
      end

      def new_enrollments
        enrollments.delete_if { |a| a.include? parameters[:trigger_and_or_cadence] }.join(',')
      end
    end
  end
end
