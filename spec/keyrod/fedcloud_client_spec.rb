require 'spec_helper'

describe Keyrod::FedcloudClient do
  subject(:fedcloud_client) { described_class.new }

  before do
    Keyrod::Settings['site'] = 'https://took666.ics.muni.cz:3000'
    Keyrod::Settings['access-token'] = 'CiG1bjnAVeoBUcKPm2Oe'
    Keyrod::Settings['group'] = 'fedcloud.egi.eu'
    Keyrod::Settings['verify-ssl'] = false
    Keyrod::Settings['ca-dir'] = '/etc/ssl/certs'
    Keyrod::Settings['identity-provider'] = 'egi.eu'

    stub_request(:get, 'https://took666.ics.muni.cz:3000/v3/OS-FEDERATION/identity_providers/egi.eu/protocols/oidc/auth')
      .with(headers: {
              'Accept' => 'application/json',
              'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
              'User-Agent' => 'Faraday v0.14.0',
              'Authorization' => 'Bearer CiG1bjnAVeoBUcKPm2Oe'
            })
      .to_return(status: 200, body: '', headers: { 'X-Subject-Token': 'GsqbMaedcZ4XTUN53DPc+VgdwjfEv' })

    stub_request(:get, 'https://took666.ics.muni.cz:3000/v3/OS-FEDERATION/identity_providers/egi.eu/protocols/oidc/auth')
      .with(headers: {
              'Accept' => 'application/json',
              'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
              'User-Agent' => 'Faraday v0.14.0',
              'Authorization' => 'Bearer failtoken'
            })
      .to_return(status: 400, body: '', headers: {})

    stub_request(:get, 'https://took666.ics.muni.cz:3000/v3/auth/projects')
      .with(headers: {
              'Accept' => 'application/json',
              'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
              'User-Agent' => 'Faraday v0.14.0',
              'X-Auth-Token' => 'GsqbMaedcZ4XTUN53DPc+VgdwjfEv'
            })
      .to_return(status: 200, body: '{"links": {"self": "","previous": null,"next": null}, "projects":
      [{"is_domain": false,"description": "","links": {"self": ""},"enabled": true,"id": "fedcloud.egi.eu",
      "parent_id": "","domain_id": "","name": "fedcloud.egi.eu"}]}', headers: {})

    stub_request(:get, 'https://took666.ics.muni.cz:3000/v3/auth/projects')
      .with(headers: {
              'Accept' => 'application/json',
              'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
              'User-Agent' => 'Faraday v0.14.0',
              'X-Auth-Token' => 'failtoken'
            })
      .to_return(status: 400, body: '', headers: {})

    stub_request(:post, 'https://took666.ics.muni.cz:3000/v3/auth/tokens')
      .with(headers: {
              'Accept' => 'application/json',
              'Content-Type' => 'application/json',
              'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
              'User-Agent' => 'Faraday v0.14.0'
            },
            body: '{"auth":{"identity":{"methods":["token"],"token":{"id":"GsqbMaedcZ4XTUN53DPc+VgdwjfEv"}},'\
            '"scope":{"project":{"id":"fedcloud.egi.eu"}}}}')
      .to_return(status: 200, body: '', headers: { 'X-Subject-Token': 'user@egi.eu:token' })
  end

  describe '#new' do
    it 'returns instance of FedcloudClient' do
      is_expected.to be_instance_of described_class
    end

    it 'sets site' do
      expect(fedcloud_client.site).to eq('https://took666.ics.muni.cz:3000')
    end

    it 'sets access-token' do
      expect(fedcloud_client.access_token).to eq('CiG1bjnAVeoBUcKPm2Oe')
    end
  end

  describe '.unscoped_token' do
    context 'with successful run' do
      it 'returns unscoped token' do
        expect(fedcloud_client.unscoped_token).to eq('GsqbMaedcZ4XTUN53DPc+VgdwjfEv')
      end

      it "doesn't raise any errors" do
        expect { fedcloud_client.unscoped_token }.not_to raise_error
      end
    end

    context 'with an error' do
      before do
        Keyrod::Settings['access-token'] = 'failtoken'
      end

      it 'raises ResponseError' do
        expect { fedcloud_client.unscoped_token }.to raise_error(Keyrod::Errors::ResponseError)
      end
    end
  end

  describe '.projects' do
    context 'with successful run' do
      let(:unscoped_token) { 'GsqbMaedcZ4XTUN53DPc+VgdwjfEv' }

      it 'returns list of projects' do
        expect(fedcloud_client.projects(unscoped_token)).to be_instance_of(Array)
        expect(fedcloud_client.projects(unscoped_token)[0]).to eq('fedcloud.egi.eu')
      end

      it "doesn't raise any errors" do
        expect { fedcloud_client.projects(unscoped_token) }.not_to raise_error
      end
    end

    context 'with an error' do
      let(:unscoped_token) { 'failtoken' }

      it 'raises ResponseError' do
        expect { fedcloud_client.projects(unscoped_token) }.to raise_error(Keyrod::Errors::ResponseError)
      end
    end
  end

  describe '.scoped_token' do
    context 'with successful run' do
      let(:unscoped_token) { 'GsqbMaedcZ4XTUN53DPc+VgdwjfEv' }
      let(:group) { 'fedcloud.egi.eu' }

      it 'returns scoped token' do
        expect(fedcloud_client.scoped_token(unscoped_token, group)).to eq('user@egi.eu:token')
      end

      it "doesn't raise any errors" do
        expect { fedcloud_client.scoped_token(unscoped_token, group) }.not_to raise_error
      end
    end
  end
end
