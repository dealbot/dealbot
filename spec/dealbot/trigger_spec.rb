describe Dealbot::Trigger do
  let (:cadence) do
    Dealbot::Cadence.parse YAML.load(<<-eof)
      best:
        cadence:
          1:
            - channel: email
              title: Immediate breakup
    eof
  end

  let (:yaml) do
    <<-eof
      hot:
        enroll:
          pipeline: 1
          stage: 2
        cadences:
          - #{ cadence.name }
          - #{ cadence.name }: #{ weight }
    eof
  end

  let (:weight) { 2 }
  let (:trig) { described_class.parse YAML.load(yaml) }

  before do
    allow(Dealbot::Cadence).to receive(:find).with(cadence.name).and_return(cadence)
  end

  context 'Good config' do
    before do
      allow(Dealbot::Configuration).to receive(:triggers).and_return([trig])
    end

    describe '.parse' do
      it 'parses YAML correctly' do
        expect(trig.name).to eq('hot')
        expect(trig.cadences.first.name).to eq(cadence.name)
        expect(trig.cadences.second.weight).to eq(weight)
      end
    end
  end

  context 'Bad config' do
    let (:yaml) do
      <<-eof
        hot:
          enroll:
            pipeline: 1
            stage: 2
          cadences:
            - [1, 2]
      eof
    end

    describe '.parse' do
      it 'throws' do
        expect{trig}.to raise_error(Dealbot::Trigger::BadCadence)
      end
    end
  end

  describe '.find' do
    before do
      allow(Dealbot::Configuration).to receive(:triggers).and_return([trig])
    end

    context 'conditions are met' do
      let (:triggerable) { double(trigger: [1, 2]) }

      it 'triggers' do
        expect(described_class.find triggerable, :enroll).not_to be_empty
      end
    end

    context 'conditions are not met' do
      let (:triggerable) { double(trigger: [1, 3]) }

      it 'does not trigger' do
        expect(described_class.find triggerable, :enroll).to be_empty
      end
    end
  end

  describe '#cadence' do
    let(:cadences) { [double(name: 'a', weight: 0), double(name: 'b', weight: 1)] }
    let(:iterations) { 10 }

    it 'respects cadence weight' do
      allow(trig).to receive(:cadences).exactly(iterations).times.and_return(cadences)
      iterations.times do
        expect(trig.cadence.name).to eq('b')
      end
    end
  end
end