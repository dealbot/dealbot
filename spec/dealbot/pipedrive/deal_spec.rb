describe Dealbot::Pipedrive::Deal do
  let (:deal) { described_class.new id: 1, person_id: 1, user_id: 1, organization_id: 1 }

  describe '#add_activity' do
    it 'posts the activity to Pipedrive' do
      expect(Dealbot::Pipedrive::Client).to receive(:request).with(:post, :activities, instance_of(Hash)).once
      deal.add_activity Hash.new
    end
  end

  describe '#add_note' do
    it 'posts the note to Pipedrive' do
      expect(Dealbot::Pipedrive::Client).to receive(:request).with(:post, :notes, instance_of(Hash)).once
      deal.add_note Hash.new
    end
  end

  describe 'metadata methods' do
    let(:name) { 'foo' }
    let(:owner_name) { 'bar' }
    let(:json) {
      {
        data: {
          title: name,
          owner_name: owner_name,
        }
      }.to_json
    }

    before do
      stub_request(:get, %r(https://api.pipedrive.com/v1/deals/1)).to_return(body: json)
    end

    it 'returns the name of the deal from Pipedrive' do
      expect(deal.name).to eq(name)
    end

    it 'returns the owner name of the deal from Pipedrive' do
      expect(deal.owner).to eq(owner_name)
    end
  end
end