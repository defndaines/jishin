defmodule Jishin.QuakeMonitor do
  @moduledoc """
  GenServer for tracking recent earthquakes.
  """

  use GenServer

  alias Jishin.Notifier
  alias Jishin.USGSClient

  defstruct subscribers: [], quake_ids: []

  # Run once per minute (in milliseconds).
  @period_ms :timer.minutes(1)

  def subscribe(%{"endpoint" => _} = subscription) do
    case valid_subscription?(subscription) do
      true ->
        sub = %{
          id: random_id(),
          start: DateTime.utc_now() |> DateTime.to_unix(:millisecond),
          details: subscription
        }

        GenServer.cast(__MODULE__, {:subscribe, subscription})
        {:ok, sub}

      false ->
        {:error, "not a valid subscription request"}
    end
  end

  def subscribe(_), do: {:error, "not a valid subscription request"}

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
    {:ok, quakes} = USGSClient.get_quakes()
    {unique_events, new_events} = new_events(quakes, state)

    # Notify any subscribers
    case new_events do
      [] ->
        :ok

      events ->
        for subscription <- state.subscribers do
          Notifier.notify(subscription, events)
        end
    end

    # Schedule next check
    schedule_check()
    {:noreply, %{state | quake_ids: unique_events}}
  end

  @impl GenServer
  def handle_cast({:subscribe, subscription}, %{subscribers: subscribers} = state) do
    {:noreply, %{state | subscribers: [subscription | subscribers]}}
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

  @doc """
  Validate a subscription request. A subscription must have at least an "endpoint". If it has
  "filters" defined, they must contain the expected fields.
  """
  def valid_subscription?(subscription) do
    subscription["endpoint"] && Enum.all?(Map.get(subscription, "filters", []), &valid_filter?/1)
  end

  # Only supporting a magnitude filter at this time.
  defp valid_filter?(%{"type" => "magnitude", "minimum" => _}), do: true
  defp valid_filter?(_), do: false

  defp schedule_check, do: Process.send_after(__MODULE__, :check, @period_ms)

  defp random_id do
    :crypto.strong_rand_bytes(7) |> Base.url_encode64(padding: false)
  end
end
