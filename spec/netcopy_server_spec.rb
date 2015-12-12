require "rack/test"

ENV["RACK_ENV"] = "test"

require_relative "../netcopy_server"

RSpec.describe "netcopy_server.rb" do
  include Rack::Test::Methods

  def app
    Sinatra::Application
  end

  describe "GET /" do
    it "displays usage info" do
      get "/"

      expect(last_response.body).to eql <<-USAGE
<pre>
Usage:

  $ echo "hello, world" | curl http://example.org -d @-
  http://example.org/2dr8p

  $ curl http://example.org/2dr8p
  "hello, world"
</pre>
      USAGE
      expect(last_response).to be_ok
    end
  end
end
