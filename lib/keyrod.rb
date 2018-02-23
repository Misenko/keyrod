module Keyrod
  autoload :CLI, 'keyrod/cli'
  autoload :Settings, 'keyrod/settings'
  autoload :OIDCClient, 'keyrod/oidc_client'
  autoload :Errors, 'keyrod/error'
end

require 'keyrod/version'
