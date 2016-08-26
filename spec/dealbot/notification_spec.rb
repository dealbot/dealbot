describe Dealbot::Pipedrive::Notification do
  let (:json) do
    <<-eof
      {
        "current": {
          "id": 1,
          "user_id": 1,
          "person_id": 1,
          "org_id": 1,
          "stage_id": 2,
          "pipeline_id": 1
        },
        "previous": {
          "id": 1,
          "user_id": 1,
          "person_id": 1,
          "org_id": 1,
          "stage_id": 1,
          "pipeline_id": 1
        },
        "event": "updated.deal"
      }
    eof
  end

  let (:notification) { described_class.parse JSON.parse(json) }

  describe '.parse' do
    it 'parses Pipedrive JSON correctly' do
      expect(notification.user_id).to eq(1)
      expect(notification.deal_id).to eq(1)
      expect(notification.person_id).to eq(1)
      expect(notification.organization_id).to eq(1)
    end
  end

  describe '#moved?' do
    it 'indicates when the notification signals a deal move' do
      expect(notification.send :moved?).to be_truthy
    end
  end

  describe '#trigger' do
    it 'reduces the notification to a representation that can trigger' do
      expect(notification.trigger).to eq([1, 2])
    end
  end

  context 'unchanged' do
    let (:json) do
      <<-eof
        {
          "current": {
            "id": 1,
            "user_id": 1,
            "person_id": 1,
            "org_id": 1,
            "stage_id": 1,
            "pipeline_id": 1
          },
          "previous": {
            "id": 1,
            "user_id": 1,
            "person_id": 1,
            "org_id": 1,
            "stage_id": 1,
            "pipeline_id": 1
          },
          "event": "updated.deal"
        }
      eof
    end

    describe '#moved?' do
      it 'indicates when the notification signals a deal non-move' do
        expect(notification.send :moved?).to be_falsey
      end
    end

    describe '#trigger' do
      it 'should not trigger when ineligible' do
        expect(notification.trigger).to be_nil
      end
    end
  end
end