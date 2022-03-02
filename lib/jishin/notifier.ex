defmodule Jishin.Notifier do
  @moduledoc """
  Service to handle notifying users who have subscribed to earthquake notifications.
  """

  use GenServer
  use Tesla

  plug(Tesla.Middleware.JSON)

  require Logger

  @doc """
  Notify a subscriber of any of the supplied events they may be interested in.
  """
  def notify(_sub, []), do: :ok

  def notify(%{"endpoint" => _endpoint} = subscription, events) do
    GenServer.cast(__MODULE__, {:notify, subscription, events})
  end

  def notify(_invalid_subscription, _), do: :ok

  ## GenServer bits

  def start_link(state), do: GenServer.start_link(__MODULE__, state, name: __MODULE__)

  @impl GenServer
  def init(state), do: {:ok, state}

  @impl GenServer
  def handle_cast({:notify, %{"endpoint" => endpoint}, events}, state) do
    for event <- events do
      post_event(endpoint, event)
    end

    {:noreply, state}
  end

  @doc """
  Get all events that match the subscription filters.
  """
  def matching(%{"filters" => []}, events), do: events

  def matching(%{"filters" => filters}, events) do
    Enum.filter(events, fn event ->
      Enum.all?(filters, fn filter -> match_filter?(filter, event) end)
    end)
  end

  def matching(_, events), do: events

  # POST a single event as JSON to an endpoint.
  defp post_event(endpoint, event) do
    case post(endpoint, event) do
      {:ok, %Tesla.Env{status: 200}} -> :ok
      {:error, reason} -> Logger.warn("issue making request: #{inspect(reason)}")
    end
  end

  # Only handling magnitude minimum.
  defp match_filter?(
         %{"type" => "magnitude", "minimum" => minimum},
         %{"properties" => %{"mag" => mag}}
       ) do
    mag >= minimum
  end

  defp match_filter?(_, _), do: false
end
