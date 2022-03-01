defmodule Jishin.QuakeMonitor do
  @moduledoc """
  GenServer for tracking recent earthquakes.
  """

  use GenServer

  alias Jishin.USGSClient

  defstruct subscribers: [], quake_ids: []

  # Run once per minute (in milliseconds).
  @period 60_000

  def start_link(subscribers) do
    GenServer.start_link(
      __MODULE__,
      %__MODULE__{subscribers: subscribers, quake_ids: []},
      name: __MODULE__
    )
  end

  @impl GenServer
  def init(state) do
    schedule_check()
    {:ok, state}
  end

  @impl GenServer
  def handle_info(:check, state) do
    # Call USGS
    {:ok, quakes} = USGSClient.get_quakes()

    {unique_events, new_events} = new_events(quakes, state)

    # Notify any subscribers

    # Schedule next check
    schedule_check()
    {:noreply, %{state | quake_ids: unique_events}}
  end

  @doc """
  Given a list of recent quakes (as returned by `Jishin.USGSClient.get_quakes/0`, check against a
  list of known events, and return a list of all unique event IDs along with the new quake
  information.
  """
  def new_events(quakes, %{quake_ids: quake_ids}) do
    unique_events = Enum.map(quakes, & &1["id"])
    new_event_ids = unique_events -- quake_ids

    new_events = Enum.filter(quakes, &(&1["id"] in new_event_ids))

    {unique_events, new_events}
  end

  defp schedule_check, do: Process.send_after(self(), :check, @period)
end
