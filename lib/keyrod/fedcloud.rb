require 'faraday'

module Keyrod
  class FedcloudClient
    def initialize(fedcloud_endpoint, access_token)
      @fedcloud_endpoint = fedcloud_endpoint
      @access_token = access_token
    end

    def unscoped_token
      conn = Faraday.new url: @fedcloud_endpoint, :ssl => {:verify => false}
      conn.authorization :Bearer, "#{@access_token}"

      response = conn.post('/v3/OS-FEDERATION/identity_providers/egi.eu/protocols/oidc/auth')
      conn = Faraday.new url: response.headers['WWW-Authenticate'].match(/(?<=\')(.*?)(?=\')/).to_s, :ssl => {:verify => false}
      conn.authorization :Bearer, "#{@access_token}"
      conn.headers['Accept'] = 'application/json'
      response = conn.post('/v3/OS-FEDERATION/identity_providers/egi.eu/protocols/oidc/auth')
      puts response.headers
    end
    
    def projects(unscoped_token)
    end

    def scoped_token(unscoped_token, group)
    end
  end
end
