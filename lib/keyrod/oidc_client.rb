require 'faraday'
require 'json'

module Keyrod
  class OIDCClient
    def initialize
      @oidc_endpoint = Keyrod::Settings['oidc-site']
      @refresh_token = Keyrod::Settings['refresh-token']
      @client_id = Keyrod::Settings['client-id']
      @client_secret = Keyrod::Settings['client-secret']
    end

    def access_token
      ssl = { verify: Keyrod::Settings['verify-ssl'] }
      ssl['ca_path'] = Keyrod::Settings['ca-dir'] if Keyrod::Settings['ca-dir']
      conn = Faraday.new(@oidc_endpoint, ssl: ssl) do |faraday|
        faraday.request  :url_encoded
        faraday.response :logger if Keyrod::Settings['debug']
        faraday.adapter  Faraday.default_adapter
      end

      response = conn.post do |req|
        req.params['grant_type'] = 'refresh_token'
        req.params['client_id'] = @client_id
        req.params['client_secret'] = @client_secret
        req.params['refresh_token'] = @refresh_token
        req.params['scope'] = 'openid profile'
      end
      raise Keyrod::Errors::ResponseError, "Response from OIDC server was #{response.status}" if response.status != 200

      JSON.parse(response.body)['access_token']
    end
  end
end
