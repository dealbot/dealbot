module Dealbot
  class Trigger < Struct.new(:name)
    class << self
      def find(triggerable, purpose)
        Configuration.triggers.select do |trigger|
          trigger.condition(purpose) == triggerable.trigger
        end
      end

      def parse(serialized)
        trigger, spec = new(serialized.to_a.flatten.first), serialized.to_a.flatten.last
        if enroll = spec['enroll']
          trigger.enroll = {
            pipeline: enroll.fetch('pipeline'),
            stage: enroll.fetch('stage'),
          }
        end
        if abandon = spec['abandon']
          trigger.abandon = {
            pipeline: abandon.fetch('pipeline'),
            stage: abandon.fetch('stage'),
          }
        end
        if cadences = spec['cadences']
          trigger.cadences = cadences.map do |c|
            case c
            when String
              Cadence.find c
            when Hash
              cadence = Cadence.find(c.first.first).dup
              cadence.weight = c.first.last
              cadence
            else
              raise BadCadence, "Bad cadence specification: #{c.inspect}"
            end
          end
        end
        trigger
      end
    end

    BadCadence = Class.new(StandardError)

    PURPOSES = %i(enroll abandon)

    attr_accessor *PURPOSES
    attr_accessor :cadences

    def cadence
      cadences.inject([]) do |memo, cadence|
        memo += Array.new cadence.weight, cadence
      end.sample
    end

    def condition(purpose)
      return false unless PURPOSES.include?(purpose)
      send(purpose).try :values
    end
  end
end