module Dealbot
  class Message < Struct.new(:command, :parameters)
    class << self
      def parse(message)
        Command.commands.find do |command|
          if message =~ /\b#{command} ?(.*)/
            return new command, ($1 || '').split(' ')
          end
        end
      end
    end
  end
end