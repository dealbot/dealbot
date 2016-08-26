module Dealbot
  class Abandonment
    CADENCE_STORAGE_FIELD_NAME = Enrollment::CADENCE_STORAGE_FIELD_NAME

    attr_reader :user_id, :person_id, :deal_id, :organization_id, :abandoner

    def initialize(abandonable:, abandoner:)
      @user_id = abandonable.user_id
      @person_id = abandonable.person_id
      @deal_id = abandonable.deal_id
      @organization_id = abandonable.organization_id
      @abandoner = abandoner
    end

    def abandon!
      Dealbot.log deal_id, "    Checking for enrollment in [#{abandoner.name}]"
      if enrolled?(enrollments)
        Dealbot.log deal_id, "    Abandoning [#{abandoner.name}]"
        Command::Abort.new.execute deal_id, "#{abandoner.name}/"
      else
        Dealbot.log deal_id, "    Not enrolled in [#{abandoner.name}], skipping"
      end
    end

    private

    def enrolled?(enrollments)
      enrollments.split(',').map { |e| e.split('/').try(:first) }.compact.include? abandoner.name
    end

    def enrollments
      @enrollments ||= JSON.parse(Pipedrive::Client.get("deals/#{deal_id}").body)['data'][Pipedrive.cadence_storage_field_id]
    end
  end
end