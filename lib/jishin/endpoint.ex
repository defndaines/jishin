defmodule Jishin.Endpoint do
  @moduledoc """
  Plug responsible for handling incoming request.
  """

  use Plug.Router

  plug(Plug.Logger)
  plug(:match)
  # Plaing after :match to ensure JSON parsing only after route match.
  plug(Plug.Parsers, parsers: [:json], json_decoder: Poison)
  plug(:dispatch)

  get "/health" do
    send_resp(conn, 200, "OK")
  end

  match _ do
    send_resp(conn, 404, "Not Found")
  end
end
