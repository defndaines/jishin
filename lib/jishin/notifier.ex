defmodule Jishin.Notifier do
  @moduledoc """
  Service to handle notifying users who have subscribed to earthquake notifications.
  """

  use GenServer

  @doc """
  Notify a subscriber of any of the supplied events they may be interested in.
  """
  def notify(_sub, []), do: :ok

  def notify(%{"endpoint" => _endpoint} = subscription, events) do
    GenServer.cast(self(), {:notify, subscription, events})
  end

  def notify(_invalid_subscription, _), do: :ok

  ## GenServer bits

  def child_spec, do: {__MODULE__, name: __MODULE__}

  def start_link(state), do: GenServer.start_link(__MODULE__, state, name: __MODULE__)

  @impl GenServer
  def init(state), do: {:ok, state}

  @impl GenServer
  def handle_cast({:notify, subscription, events}, state) do
    {:noreply, state}
  end
end
