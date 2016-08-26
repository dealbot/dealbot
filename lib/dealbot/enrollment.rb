module Dealbot
  class Enrollment
    CADENCE_STORAGE_FIELD_NAME = "Dealbot enrollments"

    attr_reader :user_id, :person_id, :deal_id, :organization_id, :cadence, :enroller

    def initialize(enrollable:, enroller:)
      @user_id = enrollable.user_id
      @person_id = enrollable.person_id
      @deal_id = enrollable.deal_id
      @organization_id = enrollable.organization_id
      @enroller = enroller
      @cadence = enroller.cadence
    end

    def enroll!
      Dealbot.log deal_id, "    Checking for previous enrollment in [#{enroller.name}]"
      if enrolled?
        Dealbot.log deal_id, "    Already enrolled in [#{enroller.name}], skipping"
      else
        Dealbot.log deal_id, "    Enrolling with [#{cadence.name}]"
        Pipedrive::Client.put "deals/#{deal_id}", Pipedrive.cadence_storage_field_id => register
        cadence.apply self, enroller
        Slack.notify self
      end
    end

    def to_s
      "#{enroller.name}/#{cadence.name}"
    end

    private

    def enrolled?
      return unless enrollments
      enrollments.split(',').map { |e| e.split('/').try(:first) }.compact.include? enroller.name
    end

    def enrollments
      @enrollments ||= JSON.parse(Pipedrive::Client.get("deals/#{deal_id}").body)['data'][Pipedrive.cadence_storage_field_id]
    end

    def register
      (enrollments || '').split(',').push(to_s).join(',')
    end
  end
end