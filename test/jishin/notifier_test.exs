defmodule Jishin.NotifierTest do
  use ExUnit.Case

  alias Jishin.Notifier

  describe "matching/2" do
    @events "priv/sample/quakes-1646157407000.json"
            |> File.read!()
            |> Jason.decode!()
            |> Map.get("features")

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
end
