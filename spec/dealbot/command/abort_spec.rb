describe Dealbot::Command::Abort do
  let (:abort) { described_class.new }
  let (:deal) { double to_s: '1' }
  let (:trigger) { 'hot' }
  let (:cadence) { 'best' }
  let (:surviving_enrollment) { 'foo/bar' }
  let (:params) { [deal, trigger] }

  before do
    allow(abort).to receive(:activities) { [activity] }
    allow(abort).to receive(:enrollments).and_return(["#{trigger}/#{cadence}", surviving_enrollment])
    allow(abort).to receive(:deal).and_return(deal)
  end

  context 'incomplete related activity' do
    let (:activity) { { 'subject' => "foobar [#{trigger}/#{cadence}]", 'done' => false, 'id' => 1 } }

    it 'destroys the activity, unregisters the enrollment, and adds a note' do
      expect(Dealbot::Pipedrive::Client).to receive(:delete).with("activities/1").once
      expect(Dealbot::Pipedrive::Client).to receive(:put).with("deals/#{deal}", Dealbot::Pipedrive.cadence_storage_field_id => surviving_enrollment).once
      expect(deal).to receive(:add_note).once
      abort.execute(*params)
    end
  end

  context 'complete related activity' do
    let (:activity) { { 'subject' => "foobar [#{trigger}/#{cadence}]", 'done' => true, 'id' => 1 } }

    it 'leaves the activity, unregisters the enrollment, and does not add a note' do
      expect(Dealbot::Pipedrive::Client).not_to receive(:delete)
      expect(Dealbot::Pipedrive::Client).to receive(:put).with("deals/#{deal}", Dealbot::Pipedrive.cadence_storage_field_id => surviving_enrollment).once
      expect(deal).not_to receive(:add_note)
      abort.execute(*params)
    end
  end

  context 'unrelated activity' do
    let (:activity) { { 'subject' => "foobar [baz/bax]", 'id' => 1 } }

    it 'leaves the activity, unregisters the enrollment, and does not add a note' do
      expect(Dealbot::Pipedrive::Client).not_to receive(:delete)
      expect(Dealbot::Pipedrive::Client).to receive(:put).with("deals/#{deal}", Dealbot::Pipedrive.cadence_storage_field_id => surviving_enrollment).once
      expect(deal).not_to receive(:add_note)
      abort.execute(*params)
    end
  end
end