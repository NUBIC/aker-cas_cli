require 'sqlite3'
require 'pathname'

require 'servers/spawned_http_server'

module Aker
  module Spec
    class RubycasServer < SpawnedHttpServer
      module Setup
        attr_accessor :cas_server
      end

      class << self
        def run_with_rspec_tag(tag, rspec_config)
          rspec_config.include Setup

          rspec_config.before(:each, tag) do
            self.cas_server = Aker::Spec::RubycasServer.new(
              :port => 6003,
              :tmpdir => tmpdir
            )
            self.cas_server.start
          end

          rspec_config.after(:each, tag) do
            if self.cas_server
              self.cas_server.stop
              self.cas_server.clear_users
            end
          end
        end
      end

      def initialize(options={})
        super({ :name => 'rubycas-server', :ssl => true }.merge(options))

        init_user_db
      end

      def add_user(username, password)
        with_user_db do |db|
          db.execute("INSERT INTO users (username, password) VALUES ('#{username}', '#{password}')")
        end
      end

      def clear_users
        with_user_db do |db|
          db.execute("DELETE FROM users")
        end
      end

      def server_command
        [
          'ruby',
          '-r',
          File.expand_path('../../disable_ssl_verify.rb', __FILE__),
          '-S',
          'rubycas-server',
          '-c',
          config_file
        ]
      end

      def config_file
        @config_file ||= write_config_file
      end

      private

      def users_db_file
        Pathname.new File.join(tmpdir, 'rubycas_users.sqlite')
      end

      def cas_db_file
        Pathname.new File.join(tmpdir, 'rubycas_db.sqlite')
      end

      def cas_log_file
        Pathname.new File.join(tmpdir, 'rubycas.log')
      end

      def with_user_db(&block)
        SQLite3::Database.new(users_db_file.to_s) do |db|
          yield db
        end
      end

      def init_user_db
        with_user_db do |db|
          db.execute(%q{
            CREATE TABLE IF NOT EXISTS users (
              username VARCHAR(50) NOT NULL, password VARCHAR(32) NOT NULL)
          })
        end
      end

      def write_config_file
        File.open(config_file_name, 'w') do |f|
          f.write config_file_template.result(binding)
        end
        config_file_name
      end

      def config_file_name
        File.join(tmpdir, 'rubycas_server_config.yml')
      end

      def config_file_template
        @config_file_template ||= ERB.new(
          File.read(File.expand_path('../rubycas_server_config.yml.erb', __FILE__)))
      end
    end
  end
end
