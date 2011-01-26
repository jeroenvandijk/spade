class FakeGemcutter
  def initialize(api_key)
    @api_key = api_key
  end

  def respond(code, text)
    [code, {"Content-Type" => "text/plain"}, text]
  end

  def call(env)
    request = Rack::Request.new(env)

    if request.env["HTTP_AUTHORIZATION"] != @api_key
      respond 401, "One cannot simply walk into Mordor!"
    elsif request.path == "/api/v1/gems" && request.post?
      respond 200, "Successfully registered rake (0.8.7)"
    elsif request.path == "/api/v1/gems/rake/owners"
      if request.post?
        respond 200, "Owner added successfully."
      elsif request.delete?
        respond 200, "Owner removed successfully."
      end
    elsif request.path == "/api/v1/gems/rake/owners.yaml" && request.get?
      yaml = YAML.dump([{'email' => 'geddy@example.com'},
                        {'email' => 'lerxst@example.com'}])
      respond(200, yaml)
    end
  end
end
