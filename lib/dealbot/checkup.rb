module Dealbot
  class Checkup
    Failed = Class.new(StandardError)

    class << self
      def perform!(hostname:nil)
        new.perform! hostname: hostname
      end
    end

    def perform!(hostname:nil)
      tasks = []
      tasks << check_for_pipedrive
      tasks << check_for_and_possibly_install_pipedrive_push_notifications(hostname)
      tasks << check_for_configuration
      tasks << check_for_and_possibly_install_pipedrive_custom_fields
      tasks.compact
    end

    private

    def check_for_pipedrive
      if Pipedrive.ok?
        "Ensured we can reach Pipedrive"
      else
        raise Failed, "Dealbot can't reach Pipedrive with the configured API key (starts with #{Pipedrive.api_key_excerpt}). Please verify your API key and correct the PIPEDRIVE_API_KEY config var from your Heroku dashboard."
      end
    end

    def check_for_and_possibly_install_pipedrive_push_notifications(hostname)
      if Pipedrive.push_notifications_in_place?
        "Ensured the Dealbot push notifications are in place at Pipedrive"
      elsif Pipedrive.install_push_notifications!(hostname) && Pipedrive.push_notifications_in_place?
        "Installed the Dealbot push notifications to your Pipedrive account"
      else
        raise Failed, "The Dealbot push notifications are not installed in your Pipedrive account and we can't seem to install them for you. Please create an issue at https://github.com/dealbot/dealbot/issues/new"
      end
    end

    def check_for_configuration
      if Configuration.ok?
        "Validated your configuration"
      else
        raise Failed, "Your configuration is missing or invalid"
      end
    end

    def check_for_and_possibly_install_pipedrive_custom_fields
      if Pipedrive.custom_fields_in_place?
        "Ensured the Dealbot custom fields are in place at Pipedrive"
      elsif Pipedrive.install_custom_fields! && Pipedrive.custom_fields_in_place?
        "Installed the Dealbot custom fields to your Pipedrive account"
      else
        raise Failed, "The Dealbot custom fields are not installed in your Pipedrive account and we can't seem to install them for you. Please create an issue at https://github.com/dealbot/dealbot/issues/new"
      end
    end
  end
end