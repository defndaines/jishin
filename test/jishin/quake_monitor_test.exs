defmodule Jishin.QuakeMonitorTest do
  use ExUnit.Case

  alias Jishin.QuakeMonitor

  describe "new_events/2" do
    @quake_ids ~w(hv72933957 ak0222rilk0c hv72933947 ak0222riitba ak0222rigai3 ak0222rieqnz ci40197112 nc73699581 ak0222ri258v nc73699576)

    test "no new events" do
      quakes = parse_file!("priv/sample/quakes-1646156807000.json")

      assert QuakeMonitor.new_events(quakes, %{quake_ids: @quake_ids}) ==
               {@quake_ids, []}
    end

    test "a new event" do
      quakes = parse_file!("priv/sample/quakes-1646157407000.json")
      latest_quake_ids = Enum.map(quakes, & &1["id"])

      # ak0222rio0t7 should be the only new event in the dataset
      new_quakes = Enum.filter(quakes, &(&1["id"] == "ak0222rio0t7"))

      {^latest_quake_ids, new_events} = QuakeMonitor.new_events(quakes, %{quake_ids: @quake_ids})
      assert new_quakes == new_events
    end
  end

  describe "valid_subscription?/1" do
    test "endpoint is enough" do
      assert QuakeMonitor.valid_subscription?(%{"endpoint" => "http://localhost"})
    end

    test "magnitude filter includes 'minimum'" do
      assert QuakeMonitor.valid_subscription?(%{
               "endpoint" => "http://localhost",
               "filters" => [%{"type" => "magnitude", "minimum" => 1.0}]
             })
    end

    test "endpoint required" do
      refute QuakeMonitor.valid_subscription?(%{
               "filters" => [%{"type" => "magnitude", "minimum" => 1.0}]
             })
    end

    test "magnitude filter requires 'type' and 'minimum'" do
      refute QuakeMonitor.valid_subscription?(%{
               "endpoint" => "http://localhost",
               "filters" => [%{"minimum" => 1.0}]
             })

      refute QuakeMonitor.valid_subscription?(%{
               "endpoint" => "http://localhost",
               "filters" => [%{"type" => "magnitude"}]
             })
    end
  end

  describe "subscribe/1" do
    test "valid subscribe responds in expected format" do
      start = DateTime.utc_now() |> DateTime.to_unix(:millisecond)

      subscription = %{
        "endpoint" => "http://localhost",
        "filters" => [%{"type" => "magnitude", "minimum" => 1.0}]
      }

      {:ok, response} = QuakeMonitor.subscribe(subscription)

      assert Map.get(response, :id)
      assert Map.get(response, :start) >= start
      assert Map.get(response, :details) == subscription
    end

    test "invalid subscribe rejected" do
      assert QuakeMonitor.subscribe(%{}) == {:error, "not a valid subscription request"}
    end
  end

  defp parse_file!(path) do
    path
    |> File.read!()
    |> Jason.decode!()
    |> Map.get("features")
  end
end
