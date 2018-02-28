require 'webmock/rspec'
require 'keyrod'
require 'yell'

WebMock.disable_net_connect!(allow_localhost: true)

RSpec.configure do |config|
  config.order = 'random'
end

Yell.new :file, '/dev/null', name: Object, level: 'error'
Object.send :include, Yell::Loggable
