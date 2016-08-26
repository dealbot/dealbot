describe Dealbot::Abandonment do
  let(:abandonable) { double Dealbot::Enrollment, deal_id: 1, person_id: 1, user_id: 1, organization_id: 1 }
  let(:abandoner) { double Dealbot::Trigger, name: 'hot' }
  let(:abandonment) { described_class.new abandonable: abandonable, abandoner: abandoner }

  describe '#abandon!' do
    context 'when enrolled' do
      before do
        allow(abandonment).to receive(:enrollments).and_return('hot/best')
      end

      it 'aborts' do
        expect_any_instance_of(Dealbot::Command::Abort).to receive(:execute).once.with(abandonable.deal_id, "#{abandoner.name}/")
        abandonment.abandon!
      end
    end

    context 'when not enrolled' do
      before do
        allow(abandonment).to receive(:enrollments).and_return('foo/bar')
      end

      it 'aborts' do
        expect_any_instance_of(Dealbot::Command::Abort).not_to receive(:execute)
        abandonment.abandon!
      end
    end
  end

  describe '#enrollments' do
    it 'pulls the deal\'s enrollments from Pipedrive' do
      allow(Dealbot::Pipedrive::Client).to receive(:get).with("deals/#{abandonable.deal_id}").and_return(double body: {'data' => { Dealbot::Pipedrive.cadence_storage_field_id => "#{abandoner.name}/x" }}.to_json)
      expect(abandonment.send(:enrollments)).to start_with(abandoner.name)
    end
  end
end