require "sinatra"
require "sqlite3"

set(:startup_hook) do
  database_file = "#{environment}.db"
  first_run = !File.exist?(database_file)
  set(:db, SQLite3::Database.new(database_file))
  if first_run
    db.execute <<-SQL
CREATE TABLE pastes (
  name VARCHAR(30),
  body BLOB
)
    SQL
  end
end

configure do
  Sinatra::Application.startup_hook
end

helpers do
  def app
    Sinatra::Application
  end
end

get "/" do
  erb :usage
end

post "/" do
  name = SecureRandom.uuid
  app.db.execute(<<-SQL, [name, request.body.read])
INSERT INTO pastes (name, body)
VALUES (?, ?)
SQL
  "/#{name}"
end

get "/:paste_name" do
  app.db.execute(<<-SQL, [params["paste_name"]]).flatten.first
SELECT body FROM pastes WHERE name = ?
SQL
end
