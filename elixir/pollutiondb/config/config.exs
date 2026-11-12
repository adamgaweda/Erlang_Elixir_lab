import Config

config :pollutiondb, ecto_repos: [Pollutiondb.Repo]

config :pollutiondb, Pollutiondb.Repo,
       adapter: Ecto.Adapters.SQLite3,
       database: "database/pollutiondb.db"

