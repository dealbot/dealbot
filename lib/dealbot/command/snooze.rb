require 'business_time'

module Dealbot
  module Command
    class Snooze < AbstractCommand
      command :snooze

      parameter :deal_id
      parameter :number_of_days

      private

      def run
        activities or return false
        changed = false
        activities.each do |activity|
          Dealbot.log 'snooze', parameters[:deal_id], "  Evaluating activity: #{activity['subject']}"
          if eligible?(activity['subject']) && !activity['done']
            old_date = Date.parse activity['due_date']
            new_date = parameters[:number_of_days].to_i.business_days.after(old_date).iso8601
            Dealbot.log 'snooze', parameters[:deal_id], "    Matches enrollment, delaying #{parameters[:number_of_days]} business days (#{old_date} to #{new_date})"
            Pipedrive::Client.put "activities/#{activity.fetch 'id'}", due_date: new_date
            changed = true
          else
            Dealbot.log 'snooze', parameters[:deal_id], "    Unrelated activity, skipping"
          end
        end
        if changed
          msg = "Snoozed for #{parameters[:number_of_days]} business days"
          deal.add_note content: "[Dealbot] #{msg}"
          msg
        else
          'No cadence activities found'
        end
      end

      def eligible?(subject)
        enrollments && enrollments.any? { |e| subject.end_with? "[#{e}]" }
      end
    end
  end
end
