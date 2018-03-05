require 'faraday'
require 'json'
require 'net/http'

module Keyrod
  class FedcloudClient
    attr_reader :site, :access_token, :auth_path, :projects_path, :scoped_path

    def initialize
      @site = Keyrod::Settings[:site]
      @access_token = Keyrod::Settings[:'access-token']
      @auth_path = '/v3/OS-FEDERATION/identity_providers/egi.eu/protocols/oidc/auth'
      @projects_path = '/v3/auth/projects'
      @scoped_path = '/v3/auth/tokens'
    end

    def unscoped_token
      conn = connection_unscoped(site)

      logger.debug "unscoped_token: Sending request with headers #{conn.headers}"
      response = conn.get

      if response.status == 401
        conn = connection_unscoped(parse_redirect(response))
        response = conn.get
      end

      raise Keyrod::Errors::ResponseError, "Response for getting unscoped token was #{response.status}" unless response.success?
      response.headers[:'X-Subject-Token']
    end

    def projects(unscoped_token)
      conn = connection_projects(site, unscoped_token)

      logger.debug "projects: Sending request with headers #{conn.headers}"
      response = conn.get

      if response.status == 401
        conn = connection_projects(parse_redirect(response), unscoped_token)
        response = conn.get
      end

      raise Keyrod::Errors::ResponseError, "Response for getting list of projects was #{response.status}" unless response.success?
      parse_projects(response.body)
    end

    def scoped_token(unscoped_token, project)
      conn = connection_scoped(site)

      logger.debug "scoped_token: Sending request with headers #{conn.headers}"
      response = conn.post do |req|
        req.body = scoped_token_body(unscoped_token, project)
      end

      if response.status == 401
        conn = connection_scoped(parse_redirect(response))
        response = conn.post do |req|
          req.body = scoped_token_body(unscoped_token, project)
        end
      end

      raise Keyrod::Errors::ResponseError, "Response for getting scoped token was #{response.status}" unless response.success?
      parse_scoped_token(response)
    end

    private

    def unscoped_token_headers
      { Authorization: "Bearer #{access_token}",
        Accept: 'application/json' }
    end

    def ssl
      ssl_params = { verify: Keyrod::Settings[:'verify-ssl'] }
      ssl_params[:ca_path] = Keyrod::Settings[:'ca-dir'] if Keyrod::Settings[:'ca-dir']
      ssl_params
    end

    def parse_redirect(response)
      response.headers['WWW-Authenticate'].match(/(?<=\')(.*?)(?=\')/).to_s
    end

    def connection_unscoped(fc_site)
      Faraday.new(fc_site + auth_path, ssl: ssl, headers: unscoped_token_headers)
    end

    def projects_headers(unscoped_token)
      { 'X-Auth-Token': unscoped_token,
        Accept: 'application/json' }
    end

    def connection_projects(fc_site, unscoped_token)
      Faraday.new(fc_site + projects_path, ssl: ssl, headers: projects_headers(unscoped_token))
    end

    def parse_projects(projects_body)
      projects = []
      project_json = JSON.parse(projects_body, symbolize_names: true)
      project_json[:projects].each do |project|
        projects << project[:id]
      end
      projects
    end

    def scoped_token_headers
      { Accept: 'application/json',
        'Content-Type': 'application/json' }
    end

    def scoped_token_body(unscoped_token, project)
      {
        auth: {
          identity: {
            methods: ['token'],
            token: {
              id: unscoped_token
            }
          },
          scope: {
            project: {
              id: project
            }
          }
        }
      }.to_json
    end

    def connection_scoped(fc_site)
      Faraday.new(fc_site + scoped_path, ssl: ssl, headers: scoped_token_headers)
    end

    def parse_scoped_token(response)
      token = response.headers[:'X-Subject-Token']
      username = JSON.parse(response.body, symbolize_names: true)[:token][:user][:name]
      "#{username}:#{token}"
    end
  end
end
