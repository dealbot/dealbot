module Dealbot
  class Route
    attr_reader :routable

    UnroutableError = Class.new(StandardError)
    DEFAULT_OUTPUT = 'OK'

    def initialize(routable)
      @routable = routable
      case routable
      when Pipedrive::Notification
        route_notification
      when Message
        route_message
      else
        raise UnroutableError, "Cannot route #{routable.class}"
      end
    end

    def to_s
      defined?(@output) ? @output : DEFAULT_OUTPUT
    end

    private

    def route_notification
      notification = routable
      Dealbot.log notification.deal_id, "Finding eligible triggers . . ."
      Trigger.find(notification, :enroll).each do |trigger|
        Dealbot.log notification.deal_id, "  Trigger [#{trigger.name}] is eligible for enrollment (#{trigger.cadences.length} candidate cadences)"
        Enrollment.new(enrollable: notification, enroller: trigger).enroll!
      end
      Trigger.find(notification, :abandon).each do |trigger|
        Dealbot.log notification.deal_id, "  Trigger [#{trigger.name}] is eligible for abandonment (#{trigger.cadences.length} candidate cadences)"
        Abandonment.new(abandonable: notification, abandoner: trigger).abandon!
      end
    end

    def route_message
      message = routable
      Dealbot.log routable.command, "Executing . . ."
      @output = Command.find(routable.command).new.execute *routable.parameters
    end
  end
end