<p align="center">
    <img alt="Keyrod" src="https://i.imgur.com/yZKRrO0.png"/>
</p>

# Keyrod
CLI for authorizing OIDC credentials against EGI Federated Cloud OpenNebula sites.

Keyrod allows to authorize either with access token or refresh token coupled with client id and client secret. After successful authentication, user receives OpenNebula login token.

## Requirements
* Ruby 2.2.6+
* Rubygems

## Installation
### From Rubygems
```bash
gem install keyrod
```
### From source
```bash
git clone https://github.com/cduongt/keyrod.git
cd keyrod
gem install bundler
bundle install
```

## Configuration
### Location
Configuration file can be saved in these paths:
* `~/.keyrod/config.yml`
* `/etc/keyrod/config.yml`
* `PATH_TO_GEM/config/config.yml` - this is default location

## Usage
```bash
$ keyrod help token

Usage:
  keyrod token -p, --identity-provider=IDENTITY-PROVIDER -s, --site=SITE

Options:
      [--debug], [--no-debug]                                # Runs Keyrod in debug mode
      [--ca-dir=CA-DIR]                                      # CA directory
      [--verify-ssl], [--no-verify-ssl]                      # Check SSL certificate of FedCloud site
                                                             # Default: true
  -s, --site=SITE                                            # EGI FedCloud Site
                                                             # Default: http://localhost/
  -a, [--access-token=ACCESS-TOKEN]                          # Access token for authentication
  -g, [--group=GROUP]                                        # Group to join
  -f, [--interactive-fallback], [--no-interactive-fallback]  # Fallback to interactive mode if group is not set
  -p, --identity-provider=IDENTITY-PROVIDER                  # Identity provider for token
  -r, [--refresh-token=REFRESH-TOKEN]                        # Refresh token for creating access token
  -o, [--oidc-site=OIDC-SITE]                                # OIDC site for authenticating refresh token
                                                             # Default: http://localhost/token
  -i, [--client-id=CLIENT-ID]                                # OIDC client ID
  -t, [--client-secret=CLIENT-SECRET]                        # OIDC client secret
```