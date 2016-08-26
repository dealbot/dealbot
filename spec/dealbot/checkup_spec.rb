describe Dealbot::Checkup do
  before do
    allow(Dealbot::Pipedrive).to receive(:ok?).and_return(true)
    allow(Dealbot::Pipedrive).to receive(:push_notifications_in_place?).and_return(true)
    allow(Dealbot::Configuration).to receive(:ok?).and_return(true)
    allow(Dealbot::Pipedrive).to receive(:custom_fields_in_place?).and_return(true)
  end

  context "All good" do
    it 'passes' do
      expect(Dealbot::Pipedrive).not_to receive(:install_push_notifications!)
      expect(Dealbot::Pipedrive).not_to receive(:install_custom_fields!)
      described_class.perform!
    end
  end

  context "Can't reach Pipedrive" do
    before do
      allow(Dealbot::Pipedrive).to receive(:ok?).and_return(false)
    end

    it 'fails' do
      expect{described_class.perform!}.to raise_error(Dealbot::Checkup::Failed)
    end
  end

  context "Pipedrive push notifications not yet in place" do
    before do
      allow(Dealbot::Pipedrive).to receive(:push_notifications_in_place?).and_return(false)
    end

    it 'installs them' do
      expect(Dealbot::Pipedrive).to receive(:install_push_notifications!) do
        allow(Dealbot::Pipedrive).to receive(:push_notifications_in_place?).and_return(true) 
      end
      described_class.perform!
    end
  end

  context "Pipedrive push notifications can't be installed" do
    before do
      allow(Dealbot::Pipedrive).to receive(:push_notifications_in_place?).and_return(false)
      allow(Dealbot::Pipedrive).to receive(:install_push_notifications!).and_return(true)
    end

    it 'fails' do
      expect{described_class.perform!}.to raise_error(Dealbot::Checkup::Failed)
    end
  end

  context "Bad configuration" do
    before do
      allow(Dealbot::Configuration).to receive(:ok?).and_return(false)
    end

    it 'fails' do
      expect{described_class.perform!}.to raise_error(Dealbot::Checkup::Failed)
    end
  end

  context "Pipedrive custom field not yet in place" do
    before do
      allow(Dealbot::Pipedrive).to receive(:custom_fields_in_place?).and_return(false)
    end

    it 'installs them' do
      expect(Dealbot::Pipedrive).to receive(:install_custom_fields!) do
        allow(Dealbot::Pipedrive).to receive(:custom_fields_in_place?).and_return(true) 
      end
      described_class.perform!
    end
  end

  context "Pipedrive custom fields can't be installed" do
    before do
      allow(Dealbot::Pipedrive).to receive(:custom_fields_in_place?).and_return(false)
      allow(Dealbot::Pipedrive).to receive(:install_custom_fields!).and_return(true)
    end

    it 'fails' do
      expect{described_class.perform!}.to raise_error(Dealbot::Checkup::Failed)
    end
  end
end