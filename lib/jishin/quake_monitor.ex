defmodule Jishin.QuakeMonitor do
  @moduledoc """
  GenServer for tracking recent earthquakes.
  """

  use GenServer

  alias Jishin.USGSClient

  # Run once per minute (in milliseconds).
  @period 60_000

  def start_link(subscribers) do
    GenServer.start_link(__MODULE__, %{subscribers: subscribers}, name: __MODULE__)
  end

  @impl GenServer
  def init(state) do
    schedule_check()
    {:ok, state}
  end

  @impl GenServer
  def handle_info(:check, state) do
    # Call USGS
    # Compare to existing knowledge (use "id" for new info)
    # Notify any subscribers
    schedule_check()
    {:noreply, state}
  end

  defp schedule_check, do: Process.send_after(self(), :check, @period)
end
