require "sinatra"
require "sqlite3"

set(:startup_hook) do
  database_file = "#{environment}.db"
  first_run = !File.exist?(database_file)
  set(:db, SQLite3::Database.new(database_file))
  db.execute("CREATE TABLE pastes (name TEXT, body BLOB)") if first_run
end

configure do
  Sinatra::Application.startup_hook
end

helpers do
  def execute(sql, bindings)
    Sinatra::Application.db.execute(sql, bindings)
  end

  def create_paste(name, body)
    execute("INSERT INTO pastes (name, body) VALUES (?, ?)", [name, body])
  end

  def find_paste(name)
    execute("SELECT body FROM pastes WHERE name = ?", [name]).flatten.first
  end
end

get "/" do
  erb :usage
end

post "/" do
  name = SecureRandom.uuid
  create_paste(name, request.body.read)
  "#{request.base_url}/#{name}"
end

get "/:paste_name" do
  content_type :text
  body = find_paste(params["paste_name"])
  body
end
