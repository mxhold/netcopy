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
        expect(paste_table_info[0]["type"]).to eql "varchar(30)"

        expect(paste_table_info[1]["name"]).to eql "body"
        expect(paste_table_info[1]["type"]).to eql "blob"
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
