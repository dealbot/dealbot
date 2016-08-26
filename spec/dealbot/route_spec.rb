describe Dealbot::Route do
  describe '.new' do
    let(:notification) { Dealbot::Pipedrive::Notification.new }
    let(:message) { Dealbot::Message.new }

    it 'routes notifications correctly' do
      expect_any_instance_of(described_class).to receive(:route_notification)
      described_class.new notification
    end

    it 'routes messages correctly' do
      expect_any_instance_of(described_class).to receive(:route_message)
      described_class.new message
    end

    it 'will not route anything else' do
      expect{described_class.new 1}.to raise_error(Dealbot::Route::UnroutableError)
    end
  end

  describe '#route_notification' do
    let (:cadence) do
      Dealbot::Cadence.parse YAML.load(<<-eof)
        best:
          cadence:
            1:
              - channel: email
                title: Immediate breakup
      eof
    end

    let (:trigger) do
      Dealbot::Trigger.parse YAML.load(<<-eof)
        hot:
          enroll:
            pipeline: 1
            stage: 2
          abandon:
            pipeline: 1
            stage: 3
          cadences:
            - #{ cadence.name }
      eof
    end

    before do
      allow(Dealbot::Cadence).to receive(:find).with(cadence.name).and_return(cadence)
      allow(Dealbot::Configuration).to receive(:triggers).and_return([trigger])
    end

    context 'Matching enrollment trigger' do
      let (:json) do
        <<-eof
          {
            "current": {
              "id": 1,
              "user_id": 1,
              "person_id": 1,
              "org_id": 1,
              "stage_id": 2,
              "pipeline_id": 1
            },
            "previous": {
              "id": 1,
              "user_id": 1,
              "person_id": 1,
              "org_id": 1,
              "stage_id": 1,
              "pipeline_id": 1
            },
            "event": "updated.deal"
          }
        eof
      end

      let(:notification) { Dealbot::Pipedrive::Notification.parse JSON.parse(json) }

      context 'Not already enrolled' do
        before do
          allow_any_instance_of(Dealbot::Enrollment).to receive(:enrollments).and_return('')
        end

        it 'creates events' do
          expect(Dealbot::Pipedrive::Client).to receive(:post).once
          expect(Dealbot::Pipedrive::Client).to receive(:put).once
          described_class.new notification
        end
      end

      context 'Already enrolled' do
        before do
          allow_any_instance_of(Dealbot::Enrollment).to receive(:enrollments).and_return("#{trigger.name}/#{cadence.name}")
        end

        it 'does not create events' do
          expect(Dealbot::Pipedrive::Client).not_to receive(:post)
          described_class.new notification
        end
      end
    end

    context 'Matching abandonment trigger' do
      let (:json) do
        <<-eof
          {
            "current": {
              "id": 1,
              "user_id": 1,
              "person_id": 1,
              "org_id": 1,
              "stage_id": 3,
              "pipeline_id": 1
            },
            "previous": {
              "id": 1,
              "user_id": 1,
              "person_id": 1,
              "org_id": 1,
              "stage_id": 1,
              "pipeline_id": 1
            },
            "event": "updated.deal"
          }
        eof
      end

      let(:notification) { Dealbot::Pipedrive::Notification.parse JSON.parse(json) }

      context 'Not already enrolled' do
        before do
          allow_any_instance_of(Dealbot::Abandonment).to receive(:enrollments).and_return('')
        end

        it 'does not destroy events' do
          expect_any_instance_of(Dealbot::Command::Abort).not_to receive(:execute)
          described_class.new notification
        end
      end

      context 'Already enrolled' do
        before do
          allow_any_instance_of(Dealbot::Abandonment).to receive(:enrollments).and_return("#{trigger.name}/#{cadence.name}")
        end

        it 'destroys events' do
          expect_any_instance_of(Dealbot::Command::Abort).to receive(:execute).once
          described_class.new notification
        end
      end
    end
  end

  describe '#route_message' do
    let (:message) { Dealbot::Message.new command: 'foo' }
    let (:command_class ) { double new: command_instance }
    let (:command_instance) { double }

    before do
      allow(Dealbot::Command).to receive(:find).and_return(command_class)
    end

    it 'delegates to a Command' do
      expect(command_instance).to receive(:execute).once
      described_class.new message
    end
  end
end