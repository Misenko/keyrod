require 'webmock/rspec'
require 'keyrod'

WebMock.disable_net_connect!(allow_localhost: true)

RSpec.configure do |config|
  config.color = true
  config.tty = true
  config.order = 'random'

  config.before do
    stub_request(:post, 'https://aai-dev.egi.eu/oidc/token?client_id=keyrod&client_secret=3HcNV88ex48UKYPWCI1OwresZAxMjh1Pdf&grant_type=refresh_token&refresh_token=iOiI0ZDQ5MzUxMC00MDJhLTQ3NDQtYjE4Yi&scope=openid%20profile')
      .with(headers: {
              'Accept' => '*/*',
              'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
              'Content-Length' => '0',
              'User-Agent' => 'Faraday v0.14.0'
            })
      .to_return(status: 200, body: '{ "access_token" : "iYWxnIjoiUlMyNTYifQ.eyJzdWIiOiI5YjU3OWJkY2"}', headers: {})
  end
end
