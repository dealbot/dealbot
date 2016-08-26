require 'mail'
require 'rest-client'
require 'json'
require 'premailer'
require 'tilt'

begin
  require 'rspec/core/rake_task'
  RSpec::Core::RakeTask.new(:spec) do |t|
    t.rspec_opts = '--require spec_helper'
  end
rescue LoadError
end

task default: :spec

Mail.defaults do
  delivery_method :smtp, {
    :address => 'smtp.sendgrid.net',
    :port => '587',
    :domain => 'heroku.com',
    :user_name => ENV['SENDGRID_USERNAME'],
    :password => ENV['SENDGRID_PASSWORD'],
    :authentication => :plain,
    :enable_starttls_auto => true
  }
end

task :setup => [:send_welcome_email, :subscribe]

task :send_welcome_email do
  html = Tilt.new('views/welcome_email.erb').render nil, key: ENV['DEALBOT_API_KEY']
  inlined_html = Premailer.new(html, with_html_string: true).to_inline_css

  Mail.deliver do
    to ENV['MAINTAINER_EMAIL']
    from "Dealbot <#{ENV['SENDGRID_USERNAME']}>"
    reply_to 'dealbot@faraday.io'
    subject 'Dealbot: Welcome! API key and next steps'
    content_type 'text/html; charset=UTF-8'
    body inlined_html
  end
end

task :subscribe do
  RestClient.get "https://faraday.us11.list-manage.com/subscribe/post-json?u=1266d4723f80c2c3e70c81732&id=6464e59052&c=?&EMAIL=#{CGI.escape ENV['MAINTAINER_EMAIL']}"
end