describe Dealbot::Command::AbstractCommand do
  let(:deal) { 1 }

  before(:all) do
    class Fly < described_class
      command :fly
      parameter :deal_id
    end
  end

  subject { Fly.new }

  describe '#activities' do
    let(:activities) { { 'data' => [] }.to_json }

    it 'pulls activities from Pipedrive' do
      expect(Dealbot::Pipedrive::Client).to receive(:get).with("deals/#{deal}/activities").and_return(double body: activities)
      subject.define_singleton_method(:run) { activities }
      subject.execute deal
    end
  end

  describe '#enrollments' do
    let(:enrollments) { { 'data' => { Dealbot::Pipedrive.cadence_storage_field_id => 'foo/bar,baz/bax' } }.to_json }

    it 'pulls enrollments from Pipedrive' do
      expect(Dealbot::Pipedrive::Client).to receive(:get).with("deals/#{deal}").and_return(double body: enrollments)
      subject.define_singleton_method(:run) { enrollments }
      subject.execute deal
    end
  end

  describe '#deal' do
    it 'encapsulates the deal' do
      subject.define_singleton_method(:run) { deal }
      expect(subject.execute(deal).id).to eq(deal)
    end
  end
end