defmodule Jishin.USGSClient do
  @moduledoc """
  Client for checking the USGS for data updates.
  """

  use Tesla
  plug(Tesla.Middleware.JSON)

  @doc """
  Request earthquake information from USGS service, returning the "features", which should be a
  list of recent activity.
  """
  def get_quakes do
    Application.get_env(:jishin, :usgs_url)
    |> get()
    |> handle_response()
  end

  defp handle_response({:ok, %Tesla.Env{status: 200, body: body}}) do
    {:ok, Map.get(body, "features", [])}
  end

  defp handle_response({:error, reason}), do: {:error, reason}
end
