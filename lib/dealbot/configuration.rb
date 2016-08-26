module Dealbot
  class Configuration
    class << self
      def ok?
        get
      end

      def triggers
        config.fetch('triggers', []).map { |t| Trigger.parse(t) }
      end

      def company
        config.fetch 'company', DEFAULTS[:company]
      end

      def cadences
        config.fetch('cadences', []).map { |c| Cadence.parse(c) }
      end

      def inspect
        get
      end

      private

      def get
        ENV['DEALBOT_CONFIG']
      end

      def config
        @config ||= YAML.load(get)
      end
    end

    DEFAULTS = {
      company: 'My company',
    }
  end
end