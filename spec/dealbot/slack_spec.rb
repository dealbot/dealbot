describe Dealbot::Slack do
  let(:incoming_webhook_url) { 'http://example.com' }

  describe '.notify' do
    context 'Enrollment' do
      let(:enrollment) { Dealbot::Enrollment.allocate }

      before do
        allow(enrollment).to receive_messages(deal_id: 1, to_s: 'hot/best')
      end

      context 'configured' do
        before do
          allow(Dealbot::Pipedrive::Deal).to receive(:new).and_return(double Dealbot::Pipedrive::Deal, name: 'Test deal', owner: 'Test owner')
          allow(described_class).to receive(:incoming_webhook_url).and_return(incoming_webhook_url)
        end

        it 'sends a message to slack' do
          expect(described_class).to receive(:send_message).once.with(/#{enrollment.to_s}/)
          described_class.notify enrollment
        end
      end

      context 'not configured' do
        it 'does not send a message to slack' do
          expect(described_class).not_to receive(:send_message)
          described_class.notify enrollment
        end
      end
    end

    context 'Unrecognized notifiable' do
      before do
        allow(described_class).to receive(:incoming_webhook_url).and_return(incoming_webhook_url)
      end

      it 'throws' do
        expect{described_class.notify 1}.to raise_error(described_class::NotNotifiableError)
      end
    end
  end

  describe '.send_message' do
    let(:message) { 'testing 123' }
    let!(:request) { stub_request :post, incoming_webhook_url }

    before do
      allow(described_class).to receive(:incoming_webhook_url).and_return(incoming_webhook_url)
    end

    it 'posts a message to slack' do
      described_class.send :send_message, message
      expect(request).to have_been_requested
    end
  end
end