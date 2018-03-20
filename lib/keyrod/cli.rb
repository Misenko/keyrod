require 'thor'
require 'yell'

module Keyrod
  class CLI < Thor
    desc 'token', 'Get login token for FedCloud site'
    option :debug,
           required: false,
           default: Keyrod::Settings['debug'],
           type: :boolean,
           desc: 'Runs Keyrod in debug mode'
    option :'ca-dir',
           required: false,
           default: Keyrod::Settings['ca-dir'],
           type: :string,
           desc: 'CA directory'
    option :'verify-ssl',
           required: false,
           default: Keyrod::Settings['verify-ssl'],
           type: :boolean,
           desc: 'Check SSL certificate of FedCloud site'
    option :site,
           required: true,
           default: Keyrod::Settings['fedcloud']['site'],
           type: :string,
           desc: 'EGI FedCloud Site',
           aliases: '-s'
    option :'access-token',
           required: false,
           default: Keyrod::Settings['fedcloud']['access_token'],
           type: :string,
           desc: 'Access token for authentication',
           aliases: '-a'
    option :group,
           required: false,
           default: Keyrod::Settings['fedcloud']['group'],
           type: :string,
           desc: 'Group to join',
           aliases: '-g'
    option :'interactive-fallback',
           required: false,
           default: Keyrod::Settings['fedcloud']['interactive-fallback'],
           type: :boolean,
           desc: 'Fallback to interactive mode if group is not set',
           aliases: '-f'
    option :'identity-provider',
           required: true,
           default: Keyrod::Settings['fedcloud']['identity-provider'],
           type: :string,
           desc: 'Identity provider for token',
           aliases: '-p'
    option :'refresh-token',
           required: false,
           default: Keyrod::Settings['oidc']['refresh_token'],
           type: :string,
           desc: 'Refresh token for creating access token',
           aliases: '-r'
    option :'oidc-site',
           required: false,
           default: Keyrod::Settings['oidc']['site'],
           type: :string,
           desc: 'OIDC site for authenticating refresh token',
           aliases: '-o'
    option :'client-id',
           required: false,
           default: Keyrod::Settings['oidc']['client_id'],
           type: :string,
           desc: 'OIDC client ID',
           aliases: '-i'
    option :'client-secret',
           required: false,
           default: Keyrod::Settings['oidc']['client_secret'],
           type: :string,
           desc: 'OIDC client secret',
           aliases: '-t'
    def token
      merge_config options
      validate_config options
      init_logger
      process_tokens
    rescue Keyrod::Errors::ParamsError => e
      abort e.message
    end

    desc 'version', 'Prints Keyrod version'
    def version
      $stdout.puts Keyrod::VERSION
    end

    default_task :token

    private

    def init_logger
      logging_level = Keyrod::Settings[:debug] ? [:debug] : [:info]
      Yell.new :stdout, name: Object, level: logging_level
      Object.send :include, Yell::Loggable
    end

    def merge_config(options)
      Keyrod::Settings.clear
      Keyrod::Settings.merge! options.to_hash
      ssl_params = { verify: Keyrod::Settings[:'verify-ssl'] }
      ssl_params[:ca_path] = Keyrod::Settings[:'ca-dir'] if Keyrod::Settings[:'ca-dir']
      Keyrod::Settings[:ssl] = ssl_params
    end

    def validate_config(options)
      raise Keyrod::Errors::ParamsError, 'Refresh/access token required' unless options[:'access-token'] || options[:'refresh-token']
      raise Keyrod::Errors::ParamsError, 'Use one of refresh/access token' if options[:'access-token'] && options[:'refresh-token']

      return unless options[:'refresh-token']
      validate_config_group options,
                            ['oidc-site', 'client-id', 'client-secret'],
                            '--oidc-site, --client-id, --client-secret are required with refresh token'
    end

    def validate_config_group(options, group, message)
      return if group.all? { |option| options[option] }

      raise Keyrod::Errors::ParamsError, message
    end

    def process_tokens
      access_token if Keyrod::Settings[:'refresh-token']

      fedcloud_client = Keyrod::FedcloudClient.new
      unscoped_token = fedcloud_client.unscoped_token
      projects = fedcloud_client.projects(unscoped_token)
      check_projects(projects)
      project = Keyrod::Settings[:group] ? Keyrod::Settings[:group] : ask('Choose one of these groups:', limited_to: projects)

      $stdout.puts fedcloud_client.scoped_token(unscoped_token, project)
    rescue Keyrod::Errors::ProjectError => e
      abort e.message
    end

    def access_token
      oidc_client = Keyrod::OIDCClient.new
      Keyrod::Settings[:'access-token'] = oidc_client.access_token
    end

    def check_projects(projects)
      return unless Keyrod::Settings[:group] && !projects.include?(Keyrod::Settings[:group])

      unless Keyrod::Settings[:'interactive-fallback']
        raise Keyrod::Errors::ProjectError, "Group #{Keyrod::Settings[:group]} is not available"
      end
      Keyrod::Settings[:group] = nil
    end
  end
end
