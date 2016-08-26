describe Dealbot::Pipedrive::Client do
  describe '.ok?' do
    context 'Pipedrive works' do
      before do
        stub_request(:get, "https://api.pipedrive.com/v1/foo?api_token=abc123").to_return(:status => 200)
       end

      it 'passes' do
        expect(described_class.ok? :foo).to be_truthy
      end
    end

    context 'Pipedrive is broken' do
      before do
        stub_request(:get, "https://api.pipedrive.com/v1/foo?api_token=abc123").to_return(:status => 500)
      end

      it 'fails' do
        expect(described_class.ok? :foo).to be_falsey
      end
    end
  end

  describe '.get and .delete' do
    %i(get delete).each do |method|
      context 'Pipedrive works' do
        before do
          stub_request(method, "https://api.pipedrive.com/v1/foo?api_token=abc123").to_return(:status => 200)
        end

        it 'passes' do
          expect(described_class.send method, :foo).to be_truthy
        end
      end

      context 'Pipedrive is broken' do
        before do
          stub_request(method, "https://api.pipedrive.com/v1/foo?api_token=abc123").to_return(:status => 404)
        end

        it 'fails' do
          expect{described_class.send method, :foo}.to raise_error(RestClient::ExceptionWithResponse)
        end
      end
    end
  end

  describe '.post and .put' do
    let (:payload) { { foo: :bar } }

    %i(post put).each do |method|
      context 'Pipedrive works' do
        before do
          stub_request(method, "https://api.pipedrive.com/v1/foo?api_token=abc123").to_return(:status => 200)
        end

        it 'passes' do
          expect(described_class.send method, :foo, payload).to be_truthy
        end
      end

      context 'Pipedrive is broken' do
        before do
          stub_request(method, "https://api.pipedrive.com/v1/foo?api_token=abc123").to_return(:status => 404)
        end

        it 'fails' do
          expect{described_class.send method, :foo, payload}.to raise_error(RestClient::ExceptionWithResponse)
        end
      end
    end
  end

  describe '.api_key' do
    let (:api_key) { 'from_env' }

    around do |example|
      ClimateControl.modify PIPEDRIVE_API_KEY: api_key do
        example.run
      end
    end

    before do
      allow(described_class).to receive(:api_key).and_call_original
      stub_const "#{described_class}::API_KEY", ENV.fetch('PIPEDRIVE_API_KEY')
    end

    it 'returns the API key from the environment' do
      expect(described_class.api_key).to eq(api_key)
    end
  end
end