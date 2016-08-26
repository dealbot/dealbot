require 'business_time'
require 'rest_client'
require 'holidays'

module Dealbot
  class Cadence < Struct.new(:name)
    class << self
      def find(name)
        find_custom(name) || find_standard(name) || raise(NotFound, "Cadence '#{name}' has not been configured, nor is it available in the Dealbot Cadence Library")
      end

      def parse(serialized)
        cadence, spec = new(serialized.to_a.flatten.first), serialized.to_a.flatten.last
        cadence.cadence =        spec.fetch 'cadence',        DEFAULTS[:cadence]
        cadence.eligible_days =  spec.fetch 'eligible_days',  DEFAULTS[:eligible_days]
        cadence.holiday_region = spec.fetch 'holiday_region', DEFAULTS[:holiday_region]
        cadence.holidays = spec['holidays'].try(:map) { |d| Date.parse d } || DEFAULTS[:holidays]
        cadence
      end

      private

      def find_custom(name)
        Configuration.cadences.find do |cadence|
          cadence.name == name
        end
      end

      def find_standard(name)
        begin
          r = RestClient.get url(name)
          r.code == 200 && parse(YAML.load(r.body))
        rescue RestClient::ExceptionWithResponse => e
          if e.response.code == 404
            false
          else
            raise e
          end
        end
      end

      def url(name)
        LIBRARY_URL_PREFIX + name.to_s + LIBRARY_URL_SUFFIX
      end
    end

    NotFound = Class.new(StandardError)

    DAYS_OF_THE_WEEK = ::Time::RFC2822_DAY_NAME.map(&:downcase).map(&:to_sym).rotate 1
    LIBRARY_URL_PREFIX = 'https://raw.githubusercontent.com/dealbot/cadences/master/'
    LIBRARY_URL_SUFFIX = '.yml'
    DEFAULTS = {
      cadence: [],
      eligible_days: (1..5).to_a,
      holiday_region: 'us',
      holidays: [],
      weight: 1,
    }

    attr_accessor :cadence, :eligible_days, :holiday_region, :holidays
    attr_writer :weight

    def apply(cadent, enroller)
      deal = Pipedrive::Deal.new id: cadent.deal_id,
                                 user_id: cadent.user_id,
                                 person_id: cadent.person_id,
                                 organization_id: cadent.organization_id

      # Say what we're going to do
      Dealbot.log deal.id, "        Applying [#{name}]"

      # Configure business_time with the cadence's work week definition
      BusinessTime::Config.work_week = eligible_days.try :map do |n|
        DAYS_OF_THE_WEEK[n.to_i.pred]
      end

      # Configure business_time with holidays
      holiday_region == 'none' or BusinessTime::Config.holidays = Holidays.between(Date.today, 2.years.from_now, holiday_region.to_sym, :observed)
      BusinessTime::Config.holidays += holidays

      cadence.each do |day, activities|
        Dealbot.log deal.id, "          Day #{day}"

        start = Time.first_business_day(Date.today)
        days = day.to_i.pred
        due_date = days.business_days.after(start).iso8601

        activities.each do |activity|
          params = {
            subject: "#{activity['title']} [#{enroller.name}/#{name}]",
            type: activity['channel'],
            due_date: due_date,
            note: activity['note']
          }
          Dealbot.log deal.id, "            #{activity['title']} (#{activity['channel']}"
          deal.add_activity params
        end
      end
    end

    def weight
      @weight ||= DEFAULTS[:weight]
    end
  end
end