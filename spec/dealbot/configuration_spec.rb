describe Dealbot::Configuration do
  before do
    described_class.instance_variable_defined?(:@config) and described_class.remove_instance_variable(:@config)
  end

  describe '.ok?' do
    context 'Configuration is present' do
      before do
        allow(described_class).to receive(:get).and_return(true)
      end

      it 'passes' do
        expect(described_class.ok?).to be_truthy
      end
    end

    context 'Configuration is missing' do
      before do
        allow(described_class).to receive(:get).and_return(nil)
      end

      it 'passes' do
        expect(described_class.ok?).to be_falsey
      end
    end
  end

  describe '.triggers' do
    let (:yaml) do
      <<-eof
        triggers:
          hot:
      eof
    end

    before do
      allow(Dealbot::Trigger).to receive(:parse).and_return(true)
      allow(described_class).to receive(:get).and_return(yaml)
    end

    it 'loads triggers from the configuration' do
      expect(described_class.triggers.length).to eq(1)
    end
  end

  describe '.company' do
    let (:company) { 'Foo' }
    let (:yaml) do
      <<-eof
        company: #{ company }
      eof
    end

    before do
      allow(described_class).to receive(:get).and_return(yaml)
    end

    it 'loads company name from the configuration' do
      expect(described_class.company).to eq(company)
    end
  end

  describe '.cadences' do
    let (:yaml) do
      <<-eof
        cadences:
          hot:
      eof
    end

    before do
      allow(Dealbot::Cadence).to receive(:parse).and_return(true)
      allow(described_class).to receive(:get).and_return(yaml)
    end

    it 'loads cadences from the configuration' do
      expect(described_class.cadences.length).to eq(1)
    end
  end


  describe '.inspect' do
    let (:yaml) { 'foo' }

    before do
      allow(described_class).to receive(:get).and_return(yaml)
    end

    it 'dumps the config' do
      expect(described_class.inspect).to eq('foo')
    end
  end

  describe '.get' do
    let (:yaml) { 'foo' }

    around do |example|
      ClimateControl.modify DEALBOT_CONFIG: yaml do
        example.run
      end
    end

    it 'takes the config from the environment' do
      expect(described_class.send :get).to eq(yaml)
    end
  end
end