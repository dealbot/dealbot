describe Dealbot::Enrollment do
  let (:deal) { double id: 1, user_id: 1, deal_id: 1, organization_id: 1, person_id: 1 }
  let (:cadence) do
    Dealbot::Cadence.parse YAML.load(<<-eof)
      best:
        cadence:
          1:
            - channel: email
              title: Immediate breakup
    eof
  end
  let (:trigger) { double name: 'hot', cadence: cadence }
  let (:enrollment) { described_class.new enrollable: deal, enroller: trigger }
  let (:cadence_storage_field_id) { Dealbot::Pipedrive.cadence_storage_field_id }

  describe '#enroll!' do
    context 'not previously enrolled' do
      before do
        allow(enrollment).to receive(:enrollments).and_return('')
      end

      it 'adds cadence activities' do
        allow(Dealbot::Pipedrive::Client).to receive(:put).with(/deals/, instance_of(Hash))
        allow(Dealbot::Slack).to receive(:notify)
        expect(cadence).to receive(:apply).once
        enrollment.enroll!
      end

      it 'records the cadence' do
        allow(cadence).to receive(:apply).once
        allow(Dealbot::Slack).to receive(:notify)
        expect(Dealbot::Pipedrive::Client).to receive(:put).with("deals/#{deal.deal_id}", { cadence_storage_field_id => "#{trigger.name}/#{cadence.name}" }).once
        enrollment.enroll!
      end

      it 'notifies Slack' do
        allow(cadence).to receive(:apply).once
        allow(Dealbot::Pipedrive::Client).to receive(:put).with(/deals/, instance_of(Hash))
        expect(Dealbot::Slack).to receive(:notify).once
        enrollment.enroll!
      end
    end

    context 'previously enrolled' do
      before do
        allow(enrollment).to receive(:enrollments).and_return("#{trigger.name}/#{cadence.name}")
      end

      it 'does not add cadence activities' do
        expect(cadence).not_to receive(:apply)
        enrollment.enroll!
      end

      it 'does not record the cadence' do
        expect(Dealbot::Pipedrive::Client).not_to receive(:put).with("deals/#{deal.deal_id}", { cadence_storage_field_id => cadence.name })
        enrollment.enroll!
      end

      it 'does not notify Slack' do
        expect(Dealbot::Slack).not_to receive(:notify)
        enrollment.enroll!
      end
    end
  end

  describe '#enrollments' do
    it 'pulls the deal\'s enrollments from Pipedrive' do
      allow(Dealbot::Pipedrive::Client).to receive(:get).with("deals/#{deal.id}").and_return(double body: {'data' => { Dealbot::Pipedrive.cadence_storage_field_id => "#{trigger.name}/#{cadence.name}"}}.to_json)
      expect(enrollment.send(:enrollments)).to eq("#{trigger.name}/#{cadence.name}")
    end
  end
end