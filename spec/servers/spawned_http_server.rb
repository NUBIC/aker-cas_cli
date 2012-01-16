require 'net/http'
require 'fileutils'
require 'childprocess'

require 'disable_ssl_verify'

module Aker
  module Spec
    class SpawnedHttpServer
      include FileUtils

      attr_reader :host, :port, :tmpdir, :name

      def initialize(options={})
        @port = options.delete(:port) or raise 'Please specify a port'
        @host = options.delete(:host) || 'localhost'
        @timeout = options.delete(:timeout) || 30
        @tmpdir = options.delete(:tmpdir) or raise 'Please specify tmpdir'
        @ssl = options.delete(:ssl) || false
        @name = options.delete(:name) || "http-#{@port}"
      end

      # @return [Array]
      def server_command
        raise NoMethodError.new 'Need to implement server_command'
      end

      def process
        @process ||= ChildProcess.build(*server_command).tap do |p|
          p.io.stdout = File.open(File.join(tmpdir, "#{name}.out"), 'w')
          p.io.stderr = File.open(File.join(tmpdir, "#{name}.err"), 'w')
        end
      end

      def start
        wait_for(
          "port #{port} to be available",
          lambda { !http_available?(base_url) },
          5)

        process.start

        wait_for(
          "#{name} to start responding",
          lambda { http_available?(base_url) },
          5)
      end

      def stop
        process.stop
        wait_for(
          "the process #{name} (#{process.pid}) to stop",
          lambda { !http_available?(base_url) },
          @timeout)
      end

      def base_url
        "http#{ssl? ? 's' : ''}://#{host}:#{port}/"
      end

      def ssl?
        @ssl
      end

      protected

      def ssl_cert
        Pathname.new File.expand_path('../integrated-test-ssl.crt', __FILE__)
      end

      def ssl_key
        Pathname.new File.expand_path('../integrated-test-ssl.key', __FILE__)
      end

      def http_available?(url)
        url = URI.parse(url)
        begin
          session = Net::HTTP.new(url.host, url.port)
          session.use_ssl = ssl?
          session.start do |http|
            status = http.get(url.request_uri).code
            # anything indicating a functioning server
            return status =~ /[1234]\d\d/
          end
        rescue => e
          false
        end
      end

      def wait_for(what, proc, timeout)
        start = Time.now
        until proc.call || (Time.now - start > timeout)
          sleep 1
        end
        unless proc.call
          raise "Wait for #{what} expired (took more than #{timeout} seconds)"
        end
      end
    end
  end
end
