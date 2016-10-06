require "./models/user"
require "./models/ping"

require "./auth"
require "./endpoints"

class Herealive::Server
  def initialize
    # DB
    path = "config/travis.yml"
    local_path = "config/database.yml"
    path = local_path if File.exists?(local_path)
    pg_connect_from_yaml(path)

    @cm = CrystalMigrations.new("src/herealive/migrations")
  end

  getter :cm

  def start
    # run migrations
    @cm.migrate

    # port
    Kemal.config.port = 8005

    #CrystalInit.start_spawned_and_wait
    CrystalInit.start
  end
end
