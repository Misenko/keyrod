require 'thor'

module Keyrod
  class CLI < Thor
    desc 'token', 'Get login token for FedCloud site'
    option :'site',
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
    option :'group',
           required: false,
           default: Keyrod::Settings['fedcloud']['group'],
           type: :string,
           desc: 'Group to join',
           aliases: '-g'
    option :'fall-back-to-interactive',
           required: false,
           default: Keyrod::Settings['fedcloud']['fallback'],
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
    def token
    end
  end
end
