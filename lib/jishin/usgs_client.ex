defmodule Jishin.USGSClient do
  @moduledoc """
  Client for checking the USGS for data updates.
  """

  def child_spec, do: {Finch, name: __MODULE__}

  @doc """
  Request earthquake information from USGS service, returning the "features", which should be a
  list of recent activity.
  """
  def get_quakes do
    :get
    |> Finch.build(Application.get_env(:jishin, :usgs_url))
    |> Finch.request(__MODULE__)
    |> handle_response()
  end

  defp handle_response({:ok, %Finch.Response{body: body}}) do
    case Jason.decode(body) do
      {:ok, response} -> {:ok, Map.get(response, "features")}
      error -> error
    end
  end

  # Some alternative responses:
  #   {:error, %Mint.TransportError{reason: :timeout}}
  defp handle_response({:error, reason}), do: {:error, reason}
end
