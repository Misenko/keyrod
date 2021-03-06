require 'spec_helper'

describe Keyrod::OIDCClient do
  subject(:oidc_client) { described_class.new }

  before do
    Keyrod::Settings['oidc-site'] = 'https://aai-dev.egi.eu/oidc/token'
    Keyrod::Settings['refresh-token'] = 'iOiI0ZDQ5MzUxMC00MDJhLTQ3NDQtYjE4Yi'
    Keyrod::Settings['client-id'] = 'keyrod'
    Keyrod::Settings['client-secret'] = '3HcNV88ex48UKYPWCI1OwresZAxMjh1Pdf'
    Keyrod::Settings['verify-ssl'] = false
    Keyrod::Settings['ca-dir'] = '/etc/ssl/certs'

    stub_request(:post, 'https://aai-dev.egi.eu/oidc/token?client_id=keyrod&client_secret=3HcNV88ex48UKYPWCI1OwresZAxMjh1Pdf&grant_type=refresh_token&refresh_token=iOiI0ZDQ5MzUxMC00MDJhLTQ3NDQtYjE4Yi&scope=openid%20profile')
      .with(headers: {
              'Accept' => '*/*',
              'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
              'Content-Length' => '0',
              'User-Agent' => 'Faraday v0.14.0'
            })
      .to_return(status: 200, body: '{ "access_token" : "iYWxnIjoiUlMyNTYifQ.eyJzdWIiOiI5YjU3OWJkY2"}', headers: {})

    stub_request(:post, 'https://aai-dev.egi.eu/oidc/token?client_id=keyroderror&client_secret=3HcNV88ex48UKYPWCI1OwresZAxMjh1Pdf&grant_type=refresh_token&refresh_token=iOiI0ZDQ5MzUxMC00MDJhLTQ3NDQtYjE4Yi&scope=openid%20profile')
      .with(headers: {
              'Accept' => '*/*',
              'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
              'Content-Length' => '0',
              'User-Agent' => 'Faraday v0.14.0'
            })
      .to_return(status: 400, body: '', headers: {})
  end

  describe '#new' do
    it 'returns instance of OIDCClient' do
      is_expected.to be_instance_of described_class
    end

    it 'sets oidc-site' do
      expect(oidc_client.oidc_site).to eq('https://aai-dev.egi.eu/oidc/token')
    end

    it 'sets refresh-token' do
      expect(oidc_client.refresh_token).to eq('iOiI0ZDQ5MzUxMC00MDJhLTQ3NDQtYjE4Yi')
    end

    it 'sets client-id' do
      expect(oidc_client.client_id).to eq('keyrod')
    end

    it 'sets client-secret' do
      expect(oidc_client.client_secret).to eq('3HcNV88ex48UKYPWCI1OwresZAxMjh1Pdf')
    end
  end

  describe '.access_token' do
    context 'with successful run' do
      it 'returns access token' do
        expect(oidc_client.access_token).to be_instance_of(String)
      end

      it "doesn't raise any errors" do
        expect { oidc_client.access_token }.not_to raise_error
      end
    end

    context 'with an error' do
      before do
        Keyrod::Settings['client-id'] = 'keyroderror'
      end
      it 'raises ResponseError' do
        expect { oidc_client.access_token }.to raise_error(Keyrod::Errors::ResponseError)
      end
    end
  end

  describe '.params' do
    it 'sets params' do
      params = oidc_client.send(:params)
      expect(params).to be_instance_of(Hash)
      expect(params[:client_id]).to eq('keyrod')
      expect(params[:client_secret]).to eq('3HcNV88ex48UKYPWCI1OwresZAxMjh1Pdf')
      expect(params[:refresh_token]).to eq('iOiI0ZDQ5MzUxMC00MDJhLTQ3NDQtYjE4Yi')
    end
  end
end
