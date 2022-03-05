defmodule Jishin.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  require Logger

  @impl true
  def start(_type, _args) do
    children = [
      # Starts a worker by calling: Jishin.Worker.start_link(arg)
      # {Jishin.Worker, arg}
      Plug.Cowboy.child_spec(
        scheme: :http,
        plug: Jishin.Endpoint,
        options: [port: Application.get_env(:jishin, :port, 4000)]
      ),
      Jishin.Notifier,
      {Jishin.QuakeMonitor, Application.get_env(:jishin, :subscribers, [])}
    ]

    opts = [strategy: :one_for_one, name: Jishin.Supervisor]
    Logger.info("Starting application ...")
    Supervisor.start_link(children, opts)
  end
end
