require 'settingslogic'

module Keyrod
  class Settings < Settingslogic
    config_file = 'config.yml'

    source "#{ENV['HOME']}/.keyrod/#{config_file}"\
    if File.exist?("#{ENV['HOME']}/.keyrod/#{config_file}")

    source "/etc/keyrod/#{config_file}"\
    if File.exist?("/etc/keyrod/#{config_file}")

    source "#{File.dirname(__FILE__)}/../../config/#{config_file}"
    namespace 'keyrod'
  end
end
