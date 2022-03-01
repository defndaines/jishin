defmodule Jishin.EndpointTest do
  @moduledoc """
  Tests against the `Jishin.Endpoint` module.
  """

  use ExUnit.Case, async: true
  use Plug.Test

  @opts Jishin.Endpoint.init([])

  test "responds to health check" do
    conn =
      conn(:get, "/health")
      |> Jishin.Endpoint.call(@opts)

    assert conn.state == :sent
    assert conn.status == 200
    assert conn.resp_body == "OK"
  end

  test "404 when no route matches" do
    conn =
      conn(:get, "/fail")
      |> Jishin.Endpoint.call(@opts)

    assert conn.status == 404
  end
end
