module Aker
  module Spec
    class SpawnedRackServer < SpawnedHttpServer
      attr_reader :rackup_file_template

      module Setup
        def spawned_rack_servers
          @spawned_rack_servers ||= {}
        end
      end

      class << self
        def run_with_rspec_tag(tag, rspec_config, options={})
          name = options[:name] || fail('Please specify a name')

          rspec_config.include Setup

          rspec_config.before(:each, tag) do
            server = SpawnedRackServer.new(options.dup)
            spawned_rack_servers[name] = server

            server.start
          end

          rspec_config.after(:each, tag) do
            spawned_rack_servers[name].stop
          end
        end
      end

      def initialize(options={})
        super(options)
        @rackup_file_template = options.delete(:rackup_file) or fail('Please specify a rackup file')
      end

      def server_command
        [
          'bundle',
          'exec',
          'thin',
          '--rackup', rackup_file,
          '--pid', pid_file,
          '--log', log_file,
          '--address', host,
          '--port', port,
          '--require', File.expand_path('../../disable_ssl_verify.rb', __FILE__),
          '--trace'
        ].tap do |cmd|
          if ssl?
            cmd.concat([
                '--ssl',
                '--ssl-key-file', ssl_key.to_s,
                '--ssl-cert-file', ssl_cert.to_s,
                '--ssl-verify'
              ])
          end
          cmd.concat(%w(start))
        end
      end

      protected

      def rackup_file
        @rackup_file ||= create_rackup_file
      end

      def create_rackup_file
        File.open(rackup_file_name, 'w') do |f|
          f.write ERB.new(File.read(rackup_file_template)).result
        end

        rackup_file_name
      end

      def rackup_file_name
        @rackup_file_name ||= tmpfile('ru')
      end

      def pid_file
        @pid_file ||= tmpfile('pid')
      end

      def log_file
        @log_file ||= tmpfile('log')
      end

      def tmpfile(ext)
        File.join(tmpdir, [name, ext].join('.'))
      end
    end
  end
end

