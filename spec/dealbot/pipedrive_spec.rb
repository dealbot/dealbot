describe Dealbot::Pipedrive do
  describe '.ok?' do
    context 'Pipedrive is up' do
      before do
        stub_request(:get, "#{described_class::Client::BASE_URL}pipelines?api_token=#{described_class::Client.api_key}").to_return(status: 200)
      end

      it 'passes' do
        expect(described_class.ok?).to be_truthy
      end
    end

    context 'Pipedrive is down' do
      before do
        stub_request(:get, "#{described_class::Client::BASE_URL}pipelines?api_token=#{described_class::Client.api_key}").to_return(status: 401)
      end

      it 'fails' do
        expect(described_class.ok?).to be_falsey
      end
    end
  end

  describe 'Push notifications' do
    before do
      stub_request(:get, "#{described_class::Client::BASE_URL}pushNotifications?api_token=#{described_class::Client.api_key}").to_return(status: 200, body: push_notifications_json)
    end

    describe '.push_notifications_in_place?' do
      context 'Push notifications are in place' do
        let(:push_notifications_json) do
          {
            success: true,
            data: [
              { subscription_url: Dealbot::Server::NOTIFICATION_PATH, event: 'added.deal'},
              { subscription_url: Dealbot::Server::NOTIFICATION_PATH, event: 'updated.deal'},
            ]
          }.to_json
        end

        it 'passes' do
          expect(described_class.push_notifications_in_place?).to be_truthy
        end
      end

      context 'Push notifications are not in place' do
        let(:push_notifications_json) do
          {
            success: true,
            data: [
              { subscription_url: 'wrong', event: 'added.deal'},
              { subscription_url: 'wrong', event: 'updated.deal'},
            ]
          }.to_json
        end

        it 'fails' do
          expect(described_class.push_notifications_in_place?).to be_falsey
        end
      end
    end

    describe '.install_push_notifications!' do
      let (:hostname) { 'example.com' }

      context 'Fresh start' do
        let(:push_notifications_json) do
          {
            success: true,
            data: [
            ]
          }.to_json
        end

        it 'installs the push notifications' do
          expect(described_class::Client).to receive(:post).with('pushNotifications', instance_of(Hash)).twice
          described_class.install_push_notifications! hostname
        end
      end

      context 'Already there' do
        let(:push_notifications_json) do
          {
            success: true,
            data: [
              { subscription_url: Dealbot::Server::NOTIFICATION_PATH, id: 1, event: 'added.deal'},
              { subscription_url: Dealbot::Server::NOTIFICATION_PATH, id: 2, event: 'updated.deal'},
            ]
          }.to_json
        end

        it 'deletes and installs the push notifications' do
          expect(described_class::Client).to receive(:delete).with(/pushNotifications\/\d/).twice
          expect(described_class::Client).to receive(:post).with('pushNotifications', instance_of(Hash)).twice
          described_class.install_push_notifications! hostname
        end
      end
    end
  end

  describe 'Custom fields' do
    before do
      stub_request(:get, "#{described_class::Client::BASE_URL}dealFields?api_token=#{described_class::Client.api_key}").to_return(status: 200, body: custom_fields_json)
    end

    describe '.custom_fields_in_place?' do
      context 'Custom fields are in place' do
        let(:custom_fields_json) do
          {
            success: true,
            data: [
              { name: Dealbot::Enrollment::CADENCE_STORAGE_FIELD_NAME },
            ]
          }.to_json
        end

        it 'passes' do
          expect(described_class.custom_fields_in_place?).to be_truthy
        end
      end

      context 'Custom fields are not in place' do
        let(:custom_fields_json) do
          {
            success: true,
            data: [
            ]
          }.to_json
        end

        it 'fails' do
          expect(described_class.custom_fields_in_place?).to be_falsey
        end
      end
    end

    describe '.install_custom_fields!' do
      context 'Fresh start' do
        let(:custom_fields_json) do
          {
            success: true,
            data: [
            ]
          }.to_json
        end

        it 'installs the custom fields' do
          expect(described_class::Client).to receive(:post).with(:dealFields, instance_of(Hash)).once
          described_class.install_custom_fields!
        end
      end

      context 'Already there' do
        let(:custom_fields_json) do
          {
            success: true,
            data: [
              { name: Dealbot::Enrollment::CADENCE_STORAGE_FIELD_NAME },
            ]
          }.to_json
        end

        it 'does nothing' do
          expect(described_class::Client).not_to receive(:post)
          described_class.install_custom_fields!
        end
      end
    end
  end

  describe '.cadence_storage_field_id' do
    let(:custom_fields_json) do
      {
        success: true,
        data: [
          { name: Dealbot::Enrollment::CADENCE_STORAGE_FIELD_NAME, key: 1 },
        ]
      }.to_json
    end

    before do
      allow(described_class).to receive(:cadence_storage_field_id).and_call_original
      stub_request(:get, "#{described_class::Client::BASE_URL}dealFields?api_token=#{described_class::Client.api_key}").to_return(body: custom_fields_json)
    end

    it 'returns the ID of the cadence storage deal field on Pipedrive' do
      expect(described_class.cadence_storage_field_id).to eq(1)
    end
  end
end