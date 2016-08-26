describe Dealbot::Message do
  describe '.parse' do
    let(:paramless_strings) { [
      '@dealbot fly',
      '@dealbot: fly',
      'fly',
    ] }
    let(:with_param) { '@dealbot: fly high' }

    before do
      allow(Dealbot::Command).to receive(:commands).and_return(%w(fly))
    end

    it 'finds the command correctly' do
      paramless_strings.push(with_param).each do |str|
        expect(described_class.parse(str)).to be_truthy
      end

    end

    it 'parses the command correctly' do
      paramless_strings.each do |str|
        expect(described_class.parse(str).command).to eq('fly')
      end
    end

    it 'parses parameters correctly' do
      paramless_strings.each do |str|
        expect(described_class.parse(str).parameters).to be_empty
      end
      expect(described_class.parse(with_param).parameters).to eq(['high'])
    end
  end
end