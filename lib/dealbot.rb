$LOAD_PATH.unshift File.dirname(__FILE__)

module Dealbot
  def route(routable)
    Route.new(routable).to_s
  end
  module_function :route

  def api_key
    ENV.fetch('DEALBOT_API_KEY')
  end
  module_function :api_key

  # :nocov:
  def log(*args)
    msg = args.pop
    args.unshift 'dealbot'
    puts args.map { |a| "[#{a}]" }.push(msg).join(' ')
  end
  # :nocov:
  module_function :log
end

require 'dealbot/enrollment'
require 'dealbot/abandonment'
require 'dealbot/pipedrive'
require 'dealbot/route'
require 'dealbot/server'
require 'dealbot/trigger'
require 'dealbot/checkup'
require 'dealbot/configuration'
require 'dealbot/cadence'
require 'dealbot/command'
require 'dealbot/command/abort'
require 'dealbot/command/snooze'
require 'dealbot/message'
require 'dealbot/slack'

require 'active_support/core_ext/module/delegation'