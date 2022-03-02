defmodule Jishin.NotifierTest do
  use ExUnit.Case

  alias Jishin.Notifier

  @events "priv/sample/quakes-1646157407000.json"
          |> File.read!()
          |> Jason.decode!()
          |> Map.get("features")

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
               ~w(detail mag place time title tsunami geometry updated url)

      assert scrubbed["id"] == event["id"]
      assert scrubbed["type"] == event["type"]
      assert scrubbed["geometry"] == event["geometry"]
    end
  end
end
