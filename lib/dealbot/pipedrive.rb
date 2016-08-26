require 'dealbot/pipedrive/notification'
require 'dealbot/pipedrive/client'
require 'dealbot/pipedrive/deal'
require 'json'

module Dealbot
  module Pipedrive
    CUSTOM_FIELDS = {
      Enrollment::CADENCE_STORAGE_FIELD_NAME => :text,
    }

    def ok?
      Client.ok? :pipelines
    end
    module_function :ok?

    def push_notifications_in_place?
      push_notifications = JSON.parse Client.get(:pushNotifications).body
      return false unless push_notifications['success']
      return false unless push_notifications['data']
      return false unless push_notifications['data'].length >= 2

      added_notification = push_notifications['data'].find do |p|
        p['subscription_url'].end_with?(Server::NOTIFICATION_PATH) && p['event'] == 'added.deal'
      end
      updated_notification = push_notifications['data'].find do |p|
        p['subscription_url'].end_with?(Server::NOTIFICATION_PATH) && p['event'] == 'updated.deal'
      end
      added_notification && updated_notification
    end
    module_function :push_notifications_in_place?

    def install_push_notifications!(hostname)
      if push_notifications = JSON.parse(Client.get(:pushNotifications).body)['data']
        push_notifications.select { |p| p['subscription_url'].end_with? Server::NOTIFICATION_PATH }.each do |p|
          Client.delete("pushNotifications/#{p['id']}")
        end
      end
      ['added.deal', 'updated.deal'].each do |event|
        Client.post "pushNotifications",
                    subscription_url: "https://#{hostname}#{Server::NOTIFICATION_PATH}",
                    event: event,
                    http_auth_user: Dealbot.api_key
      end
    end
    module_function :install_push_notifications!

    def custom_fields_in_place?
      custom_fields = JSON.parse(Client.get(:dealFields).body)['data']
      CUSTOM_FIELDS.keys.all? do |name|
        custom_fields.find do |field|
          field['name'] == name
        end
      end
    end
    module_function :custom_fields_in_place?

    def install_custom_fields!
      return true if custom_fields_in_place?
      CUSTOM_FIELDS.each do |name, type|
        Client.post :dealFields, name: name, field_type: type, add_visible_flag: false
      end
    end
    module_function :install_custom_fields!

    def cadence_storage_field_id
      @cadence_storage_field_id ||= begin
        fields = JSON.parse(Client.get(:dealFields).body)['data']
        fields.find { |f| f['name'] == Enrollment::CADENCE_STORAGE_FIELD_NAME }.try(:[], 'key')
      end
    end
    module_function :cadence_storage_field_id

    def api_key_excerpt
      Client::API_KEY.first(5)
    end
    module_function :api_key_excerpt
  end
end