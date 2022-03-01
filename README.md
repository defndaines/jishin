# Jishin

An earthquake monitoring system, which queries the USGS for recent
earthquakes and notifies subscribers of new activity.

## Usage

At this time, the project is only set up to be run in development. You can use
```shell
mix run --no-halt
```
to start up there server. It will serve at http://localhost:4000 , though the
port can be modified in the [config](config/dev.exs) if desired.
