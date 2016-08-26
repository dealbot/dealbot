module Dealbot
  module Pipedrive
    class Deal
      attr_reader :id, :person_id, :user_id, :organization_id

      def initialize(id:, person_id:nil, user_id:nil, organization_id:nil)
        @id = id
        @person_id = person_id
        @user_id = user_id
        @organization_id = organization_id
      end

      def add_activity(p)
        p.merge! params
        Client.post :activities, p
      end

      def add_note(p)
        p.merge! params.slice(:deal_id)
        Client.post :notes, p
      end

      def name
        pipedrive_data['title']
      end

      def owner
        pipedrive_data['owner_name']
      end

      private

      def pipedrive_data
        @pipedrive_data ||= JSON.parse(Client.get("deals/#{id}").body).fetch('data')
      end

      def params
        {
          user_id: user_id,
          deal_id: id,
          person_id: person_id,
          org_id: organization_id,
        }
      end
    end
  end
end