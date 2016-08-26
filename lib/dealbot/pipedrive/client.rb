require 'rest_client'
require 'json'

module Dealbot
  module Pipedrive
    class Client
      class << self
        def ok?(resource)
          get(resource).code == 200
        rescue RestClient::ExceptionWithResponse
          false
        end

        def get(resource)
          request :get, resource
        end

        def delete(resource)
          request :delete, resource
        end

        def post(resource, payload)
          request :post, resource, payload: payload.to_json
        end

        def put(resource, payload)
          request :put, resource, payload: payload.to_json
        end

        private

        def request(method, resource, options = {})
          RestClient::Request.execute({ method: method, url: url(resource), headers: { content_type: :json, params: { api_token: api_key }} }.merge(options))
        end

        def url(resource)
          BASE_URL + resource.to_s
        end

        def api_key
          API_KEY
        end
      end

      BASE_URL = 'https://api.pipedrive.com/v1/'
      API_KEY = ENV.fetch 'PIPEDRIVE_API_KEY'
    end
  end
end