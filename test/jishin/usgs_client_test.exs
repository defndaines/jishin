defmodule Jishin.USGSClientTest do
  use ExUnit.Case

  import Tesla.Mock

  alias Jishin.USGSClient

  describe "get_quakes/0" do
    test "successful call extracts features" do
      endpoint = Application.get_env(:jishin, :usgs_url)

      response =
        "priv/sample/quakes-1646157407000.json"
        |> File.read!()
        |> Jason.decode!()

      mock(fn %{method: :get, url: ^endpoint} ->
        {:ok, %Tesla.Env{status: 200, body: response}}
      end)

      {:ok, quakes} = USGSClient.get_quakes()

      assert length(quakes) == 8
      assert hd(quakes)["id"] == "ak0222rio0t7"
    end

    test "error is handled" do
      reason = "timeout?"
      mock(fn %{method: :get} -> {:error, reason} end)
      assert USGSClient.get_quakes() == {:error, reason}
    end
  end
end
