require 'spec_helper'

describe Keyrod::OIDCClient do
  subject(:oidc_client) { described_class.new }

  before do
    Keyrod::Settings['oidc-site'] = 'https://aai-dev.egi.eu/oidc/token'
    Keyrod::Settings['refresh-token'] = 'iOiI0ZDQ5MzUxMC00MDJhLTQ3NDQtYjE4Yi'
    Keyrod::Settings['client-id'] = 'keyrod'
    Keyrod::Settings['client-secret'] = '3HcNV88ex48UKYPWCI1OwresZAxMjh1Pdf'
  end

  describe '#new' do
    it 'returns instance of OIDCClient' do
      is_expected.to be_instance_of described_class
    end
  end

  describe '#access_token' do
    it 'returns access token' do
      expect(oidc_client.access_token).to be_instance_of(String)
    end
  end
end
