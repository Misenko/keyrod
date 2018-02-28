require 'faraday'
require 'json'

module Keyrod
  class OIDCClient
    attr_reader :oidc_site, :refresh_token, :client_id, :client_secret, :post_params, :ssl

    def initialize
      @oidc_site = Keyrod::Settings[:'oidc-site']
      @refresh_token = Keyrod::Settings[:'refresh-token']
      @client_id = Keyrod::Settings[:'client-id']
      @client_secret = Keyrod::Settings[:'client-secret']
      set_params
      set_ssl
    end

    def access_token
      conn = Faraday.new(oidc_site, ssl: ssl, params: post_params)

      logger.debug "Sending request with params #{conn.params}"
      response = conn.post
      logger.debug "Received response with code #{response.status} and body #{response.body}"
      raise Keyrod::Errors::ResponseError, "Response from OIDC server was #{response.status}" unless response.success?

      JSON.parse(response.body, symbolize_names: true)[:access_token]
    end

    private

    def set_params
      @post_params = { grant_type: 'refresh_token',
                       client_id: client_id,
                       client_secret: client_secret,
                       refresh_token: refresh_token,
                       scope: 'openid profile' }
    end

    def set_ssl
      @ssl = { verify: Keyrod::Settings[:'verify-ssl'] }
      ssl[:ca_path] = Keyrod::Settings[:'ca-dir'] if Keyrod::Settings[:'ca-dir']
      ssl
    end
  end
end
