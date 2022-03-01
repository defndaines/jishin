import Config

config :jishin,
  port: 4000,
  subscribers: [%{"endpoint" => "http://127.0.0.1:4000/test-notify"}]
