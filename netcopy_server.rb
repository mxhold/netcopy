require "sinatra"
require "sqlite3"

set(:startup_hook) do
  database_file = "#{environment}.db"
  first_run = !File.exist?(database_file)
  set(:db, SQLite3::Database.new(database_file))
  if first_run
    db.execute <<-SQL
      create table pastes (
        name varchar(30),
        body blob
      );
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
  app.db.execute(<<-SQL, ["abc123", request.body.read])
  INSERT INTO pastes (name, body)
  VALUES (?, ?)
SQL
  request.base_url + "/abc123"
end
