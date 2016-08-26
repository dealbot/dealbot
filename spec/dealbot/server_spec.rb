require 'rack/test'

describe Dealbot::Server do
  include Rack::Test::Methods

  def app
    described_class
  end

  let (:trigger_name) { 'hot' }
  let (:cadence_name) { 'best' }
  let (:activity_subject) { 'Immediate breakup' }
  let (:activity_channel) { 'email' }

  let (:configuration) do
    <<-eof
      triggers:
        #{ trigger_name }:
          enroll:
            pipeline: 1
            stage: 2
          cadences:
            - best
      cadences:
        #{ cadence_name }:
          cadence:
            1:
              - channel: #{ activity_channel }
                title: #{ activity_subject }
    eof
  end

  let(:pipedrive_api_key) { 'def456' }
  let(:cadence_storage_field_id) { Dealbot::Pipedrive.cadence_storage_field_id }

  before do
    allow(Dealbot::Configuration).to receive(:get).and_return(configuration)
    allow(Dealbot::Pipedrive::Client).to receive(:api_key).and_return(pipedrive_api_key)
    allow_any_instance_of(Dealbot::Enrollment).to receive(:enrollments).and_return('')
    basic_authorize Dealbot.api_key, ''
  end

  describe "POST #{described_class::NOTIFICATION_PATH}" do
    let(:payload) do
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
            "stage_id": 1,
            "pipeline_id": 1
          }
        }
      eof
    end

    before do
      stub_request(:post, "https://api.pipedrive.com/v1/activities?api_token=#{pipedrive_api_key}")
                   .with(body: "{\"subject\":\"#{activity_subject} [#{trigger_name}/#{cadence_name}]\",\"type\":\"#{activity_channel}\",\"due_date\":\"#{Time.first_business_day(Date.today).iso8601}\",\"note\":null,\"user_id\":1,\"deal_id\":1,\"person_id\":1,\"org_id\":1}")
                   .to_return(status: 200)
      stub_request(:put, "https://api.pipedrive.com/v1/deals/1?api_token=#{pipedrive_api_key}")
                   .with(body: "{\"#{cadence_storage_field_id}\":\"#{trigger_name}/#{cadence_name}\"}")
                   .to_return(status: 200)
    end

    it 'applies a cadence to a Deal' do
      post described_class::NOTIFICATION_PATH, payload
      expect(last_response).to be_ok
    end
  end

  describe 'POST /messenger_notifications' do
    let(:messages) { [
      { text: 'fly' },
      { message: 'fly' },
      { body: 'fly' },
    ]}

    before do
      allow(Dealbot::Command).to receive(:commands).and_return(%w(fly))
    end

    context 'JSON' do
      let(:payloads) { messages.map(&:to_json) }

      it 'accepts a json message' do
        payloads.each do |payload|
          expect(Dealbot).to receive(:route).once
          post '/messenger_notifications', payload, 'CONTENT_TYPE' => 'application/json'
          expect(last_response).to be_ok
        end
      end
    end

    context 'Form encoded' do
      let(:payloads) { messages }

      it 'accepts a json message' do
        payloads.each do |payload|
          expect(Dealbot).to receive(:route).once
          post '/messenger_notifications', payload
          expect(last_response).to be_ok
        end
      end
    end
  end

  describe 'GET /setup' do
    before do
      allow(Dealbot::Checkup).to receive(:perform!).and_return([])
      allow(Dealbot::Configuration).to receive(:inspect).and_return('')
    end

    it 'works' do
      get '/setup'
      expect(last_response).to be_ok
    end

    context 'Heroku' do
      it 'still works' do
        get 'https://example.herokuapp.com/setup'
        expect(last_response).to be_ok
      end
    end
  end
end