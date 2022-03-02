defmodule Jishin.Endpoint do
  @moduledoc """
  Plug responsible for handling incoming request.
  """

  use Plug.Router

  plug(Plug.Logger)
  plug(:match)
  # Placing after :match to ensure JSON parsing only after route match.
  plug(Plug.Parsers, parsers: [:json], json_decoder: Jason)
  plug(:dispatch)

  get "/health" do
    send_resp(conn, 200, "OK")
  end

  post "/subscribe" do
    case Jishin.QuakeMonitor.subscribe(conn.body_params) do
      :ok -> send_resp(conn, 200, "OK")
      {:error, _} -> send_resp(conn, 400, "Bad Request")
    end
  end

  post "/test-notify" do
    IO.inspect(conn.body_params, label: :body)
    # credo:disable-for-previous-line
    send_resp(conn, 200, "OK")
  end

  match _ do
    send_resp(conn, 404, "Not Found")
  end
end
