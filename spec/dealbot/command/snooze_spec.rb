describe Dealbot::Command::Snooze do
  let (:snooze) { described_class.new }
  let (:deal) { double to_s: '1' }
  let (:trigger) { 'hot' }
  let (:cadence) { 'best' }
  let (:surviving_enrollment) { 'foo/bar' }
  let (:original_date) { "2016-09-01" }
  let (:days) { 1 }
  let (:new_date) { "2016-09-02" }
  let (:params) { [deal, days] }

  before do
    allow(snooze).to receive(:activities) { [activity] }
    allow(snooze).to receive(:enrollments).and_return(["#{trigger}/#{cadence}", surviving_enrollment])
    allow(snooze).to receive(:deal).and_return(deal)
  end

  context 'incomplete related activity' do
    let (:activity) { { 'due_date' => original_date, 'subject' => "foobar [#{trigger}/#{cadence}]", 'done' => false, 'id' => 1 } }

    it 'delays the activity and adds a note' do
      expect(Dealbot::Pipedrive::Client).to receive(:put).with("activities/#{activity['id']}", due_date: new_date).once
      expect(deal).to receive(:add_note).once
      snooze.execute(*params)
    end
  end

  context 'complete related activity' do
    let (:activity) { { 'due_date' => original_date, 'subject' => "foobar [#{trigger}/#{cadence}]", 'done' => true, 'id' => 1 } }

    it 'leaves the activity and does not leave a note' do
      expect(Dealbot::Pipedrive::Client).not_to receive(:put)
      expect(deal).not_to receive(:add_note)
      snooze.execute(*params)
    end
  end

  context 'unrelated activity' do
    let (:activity) { { 'subject' => "foobar [baz/bax]", 'id' => 1 } }

    it 'leaves the activity and does not add a note' do
      expect(Dealbot::Pipedrive::Client).not_to receive(:put)
      expect(deal).not_to receive(:add_note)
      snooze.execute(*params)
    end
  end
end