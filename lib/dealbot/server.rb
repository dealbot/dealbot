require 'sinatra/base'

module Dealbot
  class Server < Sinatra::Base
    SECRET = Dealbot.api_key
    NOTIFICATION_PATH = '/dealbot_notifications'

    set :root, File.expand_path('../../..', __FILE__)

    use Rack::Auth::Basic, "Dealbot" do |username, _|
      username == SECRET
    end

    post NOTIFICATION_PATH do
      Dealbot.log "Received notification from Pipedrive"
      notification = Pipedrive::Notification.parse JSON.parse(request.body.read)
      Dealbot.log notification.deal_id, "Processing notification"
      Dealbot.route notification
    end

    post '/messenger_notifications' do
      Dealbot.log "Received message"
      data = case request.content_type
      when 'application/x-www-form-urlencoded'
        params
      when 'application/json'
        JSON.parse(request.body.read)
      end
      content = data['text'] || data['message'] || data['body'] or return 422
      message = Message.parse(content)
      Dealbot.log message.command, "Processing command"
      Dealbot.route message
    end

    get '/setup' do
      hostname = request.host
      tasks = Checkup.perform! hostname: hostname
      locals = { tasks: tasks, hostname: hostname, configuration: Configuration.inspect, api_key: Dealbot.api_key }
      if hostname =~ /^(.*)\.herokuapp\.com$/
        locals[:heroku_app] = $1
      else
        locals[:heroku_app] = false
      end
      erb :setup, locals: locals
    end
  end
end