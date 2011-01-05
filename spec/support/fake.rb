module SpecHelpers
  class Fake
    def call(env)
      [200, {"Content-Type" => "text/plain"}, ["Hello world!"]]
    end
  end

  def start_fake(app)
    @fake_pid = Process.fork do
      require 'thin'
      Thin::Logging.silent = true
      Rack::Handler::Thin.run(app, :Port => 9292)
    end
    ready = false
    uri   = URI.parse("http://localhost:9292/")
    until ready
      begin
        SystemTimer.timeout(1) do
          Net::HTTP.get_response(uri)
        end
        ready = true
      rescue Exception => ex
        print "-"
      end
    end
  end

  def stop_fake
    Process.kill(9, @fake_pid) if @fake_pid
  end
end
