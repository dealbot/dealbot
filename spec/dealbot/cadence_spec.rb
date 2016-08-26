describe Dealbot::Cadence do
  describe '.parse' do
    let (:yaml) do
      <<-eof
        best:
          cadence:
            1:
              - channel: email
                title: Immediate breakup
      eof
    end

    let (:cadence) { described_class.parse YAML.load(yaml) }

    it 'parses cadence YAML correctly' do
      expect(cadence.name).to eq('best')
      expect(cadence.cadence.length).to eq(1)
    end
  end

  describe '.find' do
    let(:custom_cadence_name) { 'first' }
    let(:custom_cadence) { double Dealbot::Cadence, name: custom_cadence_name }

    let(:standard_cadence_name) { 'second' }
    let(:standard_cadence_yaml) { "#{ standard_cadence_name }:\n  foo:" }

    let(:missing_cadence_name) { 'third' }
    let(:wtf_cadence_name) { 'fourth' }


    before do
      allow(Dealbot::Configuration).to receive(:cadences).and_return([custom_cadence])
      stub_request(:get, "https://raw.githubusercontent.com/dealbot/cadences/master/#{standard_cadence_name}.yml").to_return(body: standard_cadence_yaml)
      stub_request(:get, "https://raw.githubusercontent.com/dealbot/cadences/master/#{missing_cadence_name}.yml").to_return(status: 404)
      stub_request(:get, "https://raw.githubusercontent.com/dealbot/cadences/master/#{wtf_cadence_name}.yml").to_return(status: 500)
    end

    it 'first looks for a custom cadence of that name' do
      expect(described_class.find custom_cadence_name).to eq(custom_cadence)
    end

    it 'then looks online for a standard cadence' do
      expect(described_class.find(standard_cadence_name).name).to eq(standard_cadence_name)
    end

    it 'finally gives up' do
      expect{described_class.find(missing_cadence_name)}.to raise_error(Dealbot::Cadence::NotFound)
    end

    it 'or throws' do
      expect{described_class.find(wtf_cadence_name)}.to raise_error(RestClient::InternalServerError)
    end
  end

  describe '#apply' do
    let(:cadent) { double Dealbot::Enrollment, deal_id: 1, person_id: 1, user_id: 1, organization_id: 1 }
    let(:enroller) { double Dealbot::Trigger, name: 'hot' }

    let (:cadence) do
      described_class.parse YAML.load(<<-eof)
        best:
          cadence:
            1:
              - channel: email
                title: Immediate breakup
      eof
    end

    it 'adds activities' do
      expect_any_instance_of(Dealbot::Pipedrive::Deal).to receive(:add_activity).with(instance_of(Hash)).once
      cadence.apply cadent, enroller
    end
  end
end