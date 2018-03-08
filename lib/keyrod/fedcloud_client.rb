require 'faraday'
require 'json'
require 'net/http'

module Keyrod
  class FedcloudClient
    attr_reader :site, :access_token, :auth_path

    PROJECTS_PATH = '/v3/auth/projects'.freeze
    SCOPED_PATH = '/v3/auth/tokens'.freeze
    REDIRECT_HEADER = 'WWW-Authenticate'.freeze
    REDIRECT_REGEXP = /(?<=\')(.*?)(?=\')/

    def initialize
      @site = Keyrod::Settings[:site]
      @access_token = Keyrod::Settings[:'access-token']
      @auth_path = "/v3/OS-FEDERATION/identity_providers/#{Keyrod::Settings[:'identity-provider']}/protocols/oidc/auth"
    end

    def unscoped_token
      conn = connection(unscoped_token_params)

      logger.debug "unscoped_token: Sending request with headers #{conn.headers}"
      response = conn.get

      if response.status == 401
        conn = connection(unscoped_token_params(parse_redirect(response)))
        response = conn.get
      end

      raise Keyrod::Errors::ResponseError, "Response for getting unscoped token was #{response.status}" unless response.success?
      response.headers[:'X-Subject-Token']
    end

    def projects(unscoped_token)
      conn = connection(projects_params(unscoped_token))

      logger.debug "projects: Sending request with headers #{conn.headers}"
      response = conn.get

      if response.status == 401
        conn = connection(projects_params(unscoped_token, parse_redirect(response)))
        response = conn.get
      end

      raise Keyrod::Errors::ResponseError, "Response for getting list of projects was #{response.status}" unless response.success?
      parse_projects(response.body)
    end

    def scoped_token(unscoped_token, project)
      conn = connection(scoped_token_params)

      logger.debug "scoped_token: Sending request with headers #{conn.headers}"
      response = conn.post do |req|
        req.body = scoped_token_body(unscoped_token, project)
      end

      if response.status == 401
        conn = connection(scoped_token_params(parse_redirect(response)))
        response = conn.post do |req|
          req.body = scoped_token_body(unscoped_token, project)
        end
      end

      raise Keyrod::Errors::ResponseError, "Response for getting scoped token was #{response.status}" unless response.success?
      parse_scoped_token(response)
    end

    private

    def ssl
      ssl_params = { verify: Keyrod::Settings[:'verify-ssl'] }
      ssl_params[:ca_path] = Keyrod::Settings[:'ca-dir'] if Keyrod::Settings[:'ca-dir']
      ssl_params
    end

    def unscoped_token_params(fc_site = site)
      {
        site: fc_site,
        headers: { Authorization: "Bearer #{access_token}", Accept: 'application/json' },
        path: auth_path
      }
    end

    def projects_params(unscoped_token, fc_site = site)
      {
        site: fc_site,
        headers: { 'X-Auth-Token': unscoped_token, Accept: 'application/json' },
        path: PROJECTS_PATH
      }
    end

    def parse_projects(projects_body)
      projects = []
      project_json = JSON.parse(projects_body, symbolize_names: true)
      project_json[:projects].each do |project|
        projects << project[:id]
      end
      projects
    end

    def scoped_token_params(fc_site = site)
      {
        site: fc_site,
        headers: { Accept: 'application/json', 'Content-Type': 'application/json' },
        path: SCOPED_PATH
      }
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

    def parse_scoped_token(response)
      response.headers[:'X-Subject-Token']
    end

    def connection(params)
      Faraday.new(File.join(params[:site], params[:path]), ssl: ssl, headers: params[:headers])
    end

    def parse_redirect(response)
      response.headers[REDIRECT_HEADER].match(REDIRECT_REGEXP).to_s
    end
  end
end
