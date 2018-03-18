require 'faraday'
require 'json'
require 'net/http'

module Keyrod
  class FedcloudClient
    attr_reader :site, :access_token, :auth_path, :ssl

    PROJECTS_PATH = '/v3/auth/projects'.freeze
    SCOPED_PATH = '/v3/auth/tokens'.freeze
    REDIRECT_HEADER = 'WWW-Authenticate'.freeze

    def initialize
      @site = Keyrod::Settings[:site]
      @access_token = Keyrod::Settings[:'access-token']
      @auth_path = "/v3/OS-FEDERATION/identity_providers/#{Keyrod::Settings[:'identity-provider']}/protocols/oidc/auth"
      @ssl = Keyrod::Settings[:ssl]
    end

    def unscoped_token
      response = handle_response(unscoped_token_params, error_message: 'Response for getting unscoped token was')
      response.headers[:'X-Subject-Token']
    end

    def projects(unscoped_token)
      response = handle_response(projects_params(unscoped_token), error_message: 'Response for getting list of projects was')
      parse_projects(response.body)
    end

    def scoped_token(unscoped_token, project)
      response = handle_response(scoped_token_params, body: scoped_token_body(unscoped_token, project),
                                                      error_message: 'Response for getting scoped token was')
      response.headers[:'X-Subject-Token']
    end

    private

    def unscoped_token_params
      {
        site: site,
        headers: { Authorization: "Bearer #{access_token}", Accept: 'application/json' },
        path: auth_path
      }
    end

    def projects_params(unscoped_token)
      {
        site: site,
        headers: { 'X-Auth-Token': unscoped_token, Accept: 'application/json' },
        path: PROJECTS_PATH
      }
    end

    def scoped_token_params
      {
        site: site,
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

    def parse_projects(projects_body)
      project_json = JSON.parse(projects_body, symbolize_names: true)
      project_json[:projects].map { |project| project[:id] }
    end

    def parse_redirect(response)
      response.headers[REDIRECT_HEADER].downcase.sub('keystone uri=', '').delete("'")
    end

    def connection(params)
      Faraday.new(File.join(params[:site], params[:path]), ssl: ssl, headers: params[:headers])
    end

    def handle_response(params, body: nil, error_message: '')
      conn = connection(params)
      logger.debug "Sending request with headers #{conn.headers}"
      begin
        response = body ? conn.post { |req| req.body = body } : conn.get

        if response.status == 401 && response.headers[REDIRECT_HEADER]
          params[:site] = parse_redirect(response)
          response = handle_response(params, body: body, error_message: error_message)
        end
      rescue Faraday::ConnectionFailed
        raise Keyrod::Errors::ConnectionError, "Couldn't connect to site #{params[:site]}"
      end

      raise Keyrod::Errors::ResponseError, "#{error_message} #{response.status}" unless response.success?
      response
    end
  end
end
