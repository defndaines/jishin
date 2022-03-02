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

  test "responds to subscribe request" do
    conn =
      conn(:post, "/subscribe", %{"endpoint" => "http://localhost:4001/test-notify"})
      |> Jishin.Endpoint.call(@opts)

    assert conn.state == :sent
    assert conn.status == 200
    assert String.contains?(conn.resp_body, "details")
    assert String.contains?(conn.resp_body, "start")
    assert String.contains?(conn.resp_body, "id")
  end

  test "400 when bad subscription request" do
    conn =
      conn(:post, "/subscribe", %{"endpointer" => "http://nope"})
      |> Jishin.Endpoint.call(@opts)

    assert conn.state == :sent
    assert conn.status == 400
    assert conn.resp_body == "Bad Request"
  end

  test "404 when no route matches" do
    conn =
      conn(:get, "/fail")
      |> Jishin.Endpoint.call(@opts)

    assert conn.status == 404
  end
end
