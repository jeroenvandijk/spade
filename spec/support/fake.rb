module SpecHelpers
  class Fake
    def call(env)
      [200, {"Content-Type" => "text/plain"}, ["Hello world!"]]
    end
  end

  def start_fake(app)
    @fake_pid = Process.fork do
      logger = Logger.new(StringIO.new)
      Rack::Handler::WEBrick.run(app, :Port => 9292, :Logger => logger, :AccessLog => logger)
    end
    ready = false
    uri   = URI.parse("http://localhost:9292/")
    until ready
      begin
        timeout(1) do
          Net::HTTP.get_response(uri)
        end
        ready = true
      rescue Exception => ex
        print "-" if ENV["VERBOSE"]
      end
    end
  end

  def stop_fake
    Process.kill(9, @fake_pid) if @fake_pid
  end
end
