defmodule Chatbot.Controllers.Base do
  @moduledoc false
  
  alias Plug.Conn

  def render_json(conn, status, data) do
    body = Jason.encode!(data)
    Conn.send_resp(conn, status || 200, body)
  end

  def render_string(conn, status, data) do
    Conn.send_resp(conn, status || 200, data)
  end
end