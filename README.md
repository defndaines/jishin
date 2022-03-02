# 地震 [Jishin]

An earthquake monitoring system, which queries the United States Geological
Survey [USGS] for recent earthquakes and notifies subscribers of new activity.

## Usage

At this time, the project is only set up to run in development. You can use
```shell
mix run --no-halt
```
to start up the server. It will respond at http://localhost:4000, though the
port can be modified in the [config](config/dev.exs) if desired.

### Subscribe

The `/subscribe` endpoint allows for registering a webhook to be notified of
earthquakes. POST a payload like the following:
```json
{ "endpoint": "https://receiver.mywebservice.com/earthquakes"
, "filters": [
    { "type": "magnitude"
    , "minimum": 3.0
    }
  ]
}
```

Using `curl`:
```shell
curl -XPOST -H 'Content-Type:application/json' \
  -d @priv/sample/sub-mag-1.json \
  http://localhost:4000/subscribe
```

### Configuration

There are a few fields that can be configured per `MIX_ENV` environment.

```elixir
config :jishin,
  port: 4000,
  usgs_url: "https://earthquake.usgs.gov/earthquakes/feed/v1.0/summary/1.0_hour.geojson",
  subscribers: []
```

- `port` Port the server responds to when started. (Test defaults to
  4001.)
- `usgs_url` URL to issue GET requests to for earthquake information. Can be
  changed to a test URL if needed, provided the response format conforms..
- `subscribers` Where to send notifications of new earthquakes. In
  development, it is set to the following so that it "echos" back to the same
  instance for testing and diagnostics.
```
  subscribers: [%{"endpoint" => "http://127.0.0.1:4000/test-notify"}]
```
