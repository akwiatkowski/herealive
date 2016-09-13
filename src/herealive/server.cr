class Herealive::Server
  def initialize
    path = "config/travis.yml"
    local_path = "config/database.yml"
    path = local_path if File.exists?(local_path)
    pg_connect_from_yaml(path)

    cm = CrystalMigrations.new("src/herealive/migrations")
    cm.migrate

    CrystalInit.start_spawned_and_wait
  end
end
