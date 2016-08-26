describe Dealbot::Command do
  before(:all) do
    class Swim < described_class::AbstractCommand
      command :swim
      parameter :deal_id
    end
  end

  describe '.find' do
    context 'exists' do
      it 'finds the right command' do
        expect(described_class.find :swim).to eq(Swim)
      end
    end

    context 'does not exist' do
      it 'fails' do
        expect(described_class.find :jump).to be_falsey
      end
    end
  end

  describe '.commands' do
    it 'includes established commands' do
      expect(described_class.commands).to include(:swim)
    end

    it 'does not include unknown commands' do
      expect(described_class.commands).not_to include(:jump)
    end
  end
end