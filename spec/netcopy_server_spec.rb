ENV["RACK_ENV"] = "test"
require "rack/test"
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

  $ echo "hello, world" | curl http://example.org --data-binary @-
  http://example.org/3cdf55b6-2ffe-42c9-97be-d94ef66e58c6

  $ curl http://example.org/3cdf55b6-2ffe-42c9-97be-d94ef66e58c6
  hello, world
</pre>
      USAGE
    end
  end

  describe "POST /" do
    it "creates a paste" do
      post "/", "hello, world!"

      last_paste_body = app.db.execute(
        "SELECT body FROM pastes ORDER BY rowid DESC LIMIT 1"
      ).flatten.first

      expect(last_paste_body).to eql "hello, world!"
    end

    it "assigns and returns a unique name to the paste" do
      post "/", "hello, world!"
      paste1_name = last_response.body

      post "/", "hello, world!"
      paste2_name = last_response.body

      expect(paste1_name).not_to eql paste2_name
    end
  end

  describe "GET /:paste_name" do
    it "returns the body of the specified paste" do
      post "/", "hello, world!"
      get last_response.body.sub(last_request.base_url, "")

      expect(last_response.body).to eql "hello, world!"
    end
  end

  describe "server start" do
    before do
      FileUtils.rm("test.db") if File.exist?("test.db")
    end

    it "creates a database" do
      expect(File.exist?("test.db")).to be false

      app.startup_hook

      expect(File.exist?("test.db")).to be true
    end

    context "first run" do
      it "creates a pastes table" do
        app.startup_hook

        paste_table_info = app.db.table_info("pastes")

        expect(paste_table_info[0]["name"]).to eql "name"
        expect(paste_table_info[0]["type"]).to eql "TEXT"

        expect(paste_table_info[1]["name"]).to eql "body"
        expect(paste_table_info[1]["type"]).to eql "BLOB"
      end
    end

    context "subsequent runs" do
      it "does not attempt to create the pastes table" do
        app.startup_hook

        expect { app.startup_hook }.not_to raise_error
      end
    end
  end
end
