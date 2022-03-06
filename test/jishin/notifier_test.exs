defmodule Jishin.NotifierTest do
  use ExUnit.Case

  import Tesla.Mock

  alias Jishin.Notifier

  @events "priv/sample/quakes-1646157407000.json"
          |> File.read!()
          |> Jason.decode!()
          |> Map.get("features")

  describe "notify/2" do
    @endpoint "http://localhost:4001/webhook"

    setup do
      mock(fn %{method: :post, url: @endpoint} ->
        {:ok, %Tesla.Env{status: 200}}
      end)

      :ok
    end

    test "notify with empty filters" do
      assert Notifier.notify(%{"endpoint" => @endpoint, "filters" => []}, @events) == :ok
    end

    test "notify with nil filters" do
      assert Notifier.notify(%{"endpoint" => @endpoint}, @events) == :ok
    end

    test "with no events doesn't trigger requests" do
      assert Notifier.notify(%{"endpoint" => @endpoint}, []) == :ok
    end

    test "with invalid sub doesn't crash" do
      assert Notifier.notify(%{"endpointe" => @endpoint}, @events) == :ok
    end
  end

  describe "matching/2" do
    test "matches filter" do
      subscription = %{"filters" => [%{"type" => "magnitude", "minimum" => 2.0}]}
      matched = Notifier.matching(subscription, @events)
      assert length(matched) == 2
      assert Enum.map(matched, & &1["id"]) == ["hv72933957", "ci40197112"]
    end

    test "nothing matches filter" do
      subscription = %{"filters" => [%{"type" => "magnitude", "minimum" => 3.0}]}
      matched = Notifier.matching(subscription, @events)
      assert matched == []
    end

    test "matches everything" do
      subscription = %{"filters" => [%{"type" => "magnitude", "minimum" => 1.0}]}
      matched = Notifier.matching(subscription, @events)
      assert @events == matched
    end
  end

  describe "select_fields/1" do
    test "removes additional fields" do
      event = hd(@events)

      # Sanity check input
      assert length(Map.keys(event["properties"])) == 26

      scrubbed = Notifier.select_fields(event)

      assert length(Map.keys(scrubbed["properties"])) == 9

      assert Map.keys(scrubbed["properties"]) ==
               ~w(detail mag place time title tsunami type updated url)

      assert scrubbed["id"] == event["id"]
      assert scrubbed["type"] == event["type"]
      assert scrubbed["geometry"] == event["geometry"]
    end
  end
end
