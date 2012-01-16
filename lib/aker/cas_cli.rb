require 'aker'
require 'mechanize'
require 'uri'
require 'cgi'

module Aker
  class CasCli
    autoload :VERSION, 'aker/cas_cli/version'

    include Aker::Cas::ConfigurationHelper

    CLI_SERVICE = 'https://cas-cli.example.edu'

    ##
    # @return [Aker::Configuration] the Aker parameters governing this
    #   instance.
    attr_reader :configuration

    ##
    # Creates a new instance.
    #
    # @param [Aker::Configuration] configuration the Aker
    #   configuration to use. This configuration should have the :cas
    #   authority (or an appropriate substitute) configured into its
    #   authority chain.
    # @param [Hash] mechanize_options attribute values for the
    #   mechanize agent used to do the scraping. Use this, e.g., to
    #   specify the SSL CA to use.
    def initialize(configuration, mechanize_options={})
      @configuration = configuration
      @agent = Mechanize.new do |a|
        mechanize_options.each do |attr, value|
          a.send("#{attr}=", value)
        end
        a.redirect_ok = false
      end
    end

    ##
    # Attempts to verify the provided credentials. Verification is
    # attempted through screen-scraping the login form provided by the
    # CAS server configured in {#configuration}.
    #
    # @return [Aker::User,nil] the authenticated user, or nil if the
    #   credentials are invalid.
    def authenticate(username, password)
      login_result = do_login(username, password)
      return unless login_result

      if st = extract_service_ticket_if_successful(login_result)
        configuration.composite_authority.valid_credentials?(:cas, st, CLI_SERVICE)
      end
    end

    private

    # @return [Mechanize::Page]
    def do_login(username, password)
      login_page = @agent.get cas_login_url, :service => CLI_SERVICE
      login_form = login_page.forms.find { |f| f.field_with(:name => 'username') }
      login_form['username'] = username
      login_form['password'] = password
      begin
        login_form.submit
      rescue Mechanize::UnauthorizedError
        nil
      end
    end

    def extract_service_ticket_if_successful(result_page)
      if result_page.code =~ /^3\d\d$/
        location = result_page.header['Location']
        return unless location && location =~ %r{^#{Regexp.escape CLI_SERVICE}}

        target = URI.parse(location)
        return unless target.query

        CGI.parse(target.query)['ticket'].first
      end
    end
  end
end
