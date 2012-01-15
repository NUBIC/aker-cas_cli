require 'spec_helper'
require 'aker'

module Aker
  describe CasCli, :integrated do
    let(:cas_cli) { CasCli.new(aker_config) }

    let(:username) { 'mr261' }
    let(:correct_password) { 's3r3nity' }

    let(:aker_config) {
      server = cas_server
      logfile = File.join(tmpdir, 'aker.log')
      Aker::Configuration.new do
        authority :cas
        cas_parameters :cas_base_url => server.base_url
        logger Logger.new(File.open(logfile, 'w'))
      end
    }

    before do
      cas_server.add_user(username, correct_password)
    end

    context 'when authenticating' do
      it 'returns an Aker::User for valid credentials' do
        cas_cli.authenticate(username, correct_password).should be_an Aker::User
      end

      it 'returns nil for invalid credentials' do
        cas_cli.authenticate(username, 'bilbo').should be_nil
      end
    end

    context 'an authenticated user' do
      let(:user) { cas_cli.authenticate(username, correct_password) }
      let(:service_url) { 'https://srvc.example.net/mail' }

      it 'has the correct username' do
        user.username.should == username
      end

      it 'can request PTs' do
        pending
        lambda { user.cas_proxy_ticket(service_url) }.should_not raise_error
      end

      it 'receives valid PTs' do
        pending
        pt = user.cas_proxy_ticket(service_url)
        proxied = Aker.authority.valid_credentials?(:cas_proxy, pt, service_url)
        proxied.username.should == user.username
      end
    end
  end
end
