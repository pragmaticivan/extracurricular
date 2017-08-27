use Mix.Config

config :data,
  ecto_repos: [Data.Repo],
  levels: ["starter", "intermediate", "advanced"],
  types: ["bug", "discussion", "enhancement", "feature"]

config :data, Data.Repo,
  loggers: [Appsignal.Ecto, Ecto.LogEntry]

import_config "#{Mix.env}.exs"
