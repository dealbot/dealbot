require 'dealbot/command/abstract_command'

module Dealbot
  module Command
    def find(command)
      AbstractCommand.descendants.find { |c| c.commands.include? command }
    end
    module_function :find

    def commands
      @commands ||= AbstractCommand.descendants.map(&:commands).flatten
    end
    module_function :commands
  end
end