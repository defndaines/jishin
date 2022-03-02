import Config

config :jishin,
  port: 4000,
  usgs_url: "https://earthquake.usgs.gov/earthquakes/feed/v1.0/summary/1.0_hour.geojson",
  subscribers: []

config :tesla, adapter: Tesla.Adapter.Hackney

import_config "#{Mix.env()}.exs"
