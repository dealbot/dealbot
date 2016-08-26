module Dealbot
  class Slack
    class << self
      def notify(notifiable)
        return unless configured?
        case notifiable
        when Enrollment
          notify_enrollment notifiable
        else
          raise NotNotifiableError, "No notifier available for #{notifiable.class}"
        end
      end

      private

      def configured?
        !!incoming_webhook_url
      end

      def notify_enrollment(enrollment)
        deal = Pipedrive::Deal.new(id: enrollment.deal_id)
        send_message ":clapper: *#{deal.owner}* enrolled *#{deal.name}* in *#{enrollment}*"
      end

      def send_message(message)
        json = { text: message }.to_json
        RestClient.post incoming_webhook_url, json, content_type: :json
      end

      def incoming_webhook_url
        @incoming_webhook_url ||= ENV['SLACK_INCOMING_WEBHOOK_URL']
      end
    end

    NotNotifiableError = Class.new(StandardError)
  end
end
