require 'thor'

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
    end

    desc 'version', 'Prints Keyrod version'
    def version
      puts Keyrod::VERSION
    end

    default_task :token

    private

    def merge_config(options)
      Keyrod::Settings.clear
      Keyrod::Settings.merge! options.to_hash
    end
  end
end
