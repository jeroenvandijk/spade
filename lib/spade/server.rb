require 'rack'
require 'rack/static'
require 'tempfile'
require 'child_labor'

module Spade
  module Server
    def self.run(working, port)
      rootdir = Spade.discover_root(working)
      static = Rack::Static.new(nil, :urls => ['/'], :root => rootdir)
      static = CommandRunner.new(static)
      static = Rack::ShowStatus.new(Rack::ShowExceptions.new(Rack::Chunked.new(Rack::ContentLength.new(static))))

      Rack::Handler::WEBrick.run static, :Port => port.to_i
    end

    def self.shutdown
      Rack::Handler::WEBrick.shutdown
    end

    class CommandRunner
      def initialize(app)
        @app = app
      end

      #FIXME: This is not very safe, we should have some restrictions
      def call(env)
        if env['PATH_INFO'] == '/_spade/command'
          rack_input = env["rack.input"].read
          params = Rack::Utils.parse_query(rack_input, "&")

          command_path = params['command']
          return [500, {}, "command required"] if command_path.nil? || command_path.empty?

          if ((root = params['pkgRoot']) && !root.nil?)
            command_path = File.expand_path(File.join(command_path), root)
          end

          tempfile = Tempfile.new('spade-server')
          tempfile.write(params['code'])
          tempfile.close


          puts "Running: #{command_path}"

          output, error = nil
          process = ChildLabor.subprocess("#{command_path} < #{tempfile.path}") do |p|
            output = p.read
            error = p.read_stderr
          end

          tempfile.delete

          if process.exit_status == 0
            [200, {}, output]
          else
            [500, {}, error]
          end
        else
          @app.call(env)
        end
      end
    end
  end
end
