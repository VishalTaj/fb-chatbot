defmodule Chatbot.Router do
  use Plug.Router

  plug(Plug.Parsers,
    parsers: [:json],
    pass: ["text/*"],
    json_decoder: Jason
  )

  plug(:match)
  plug(:dispatch)

  alias Chatbot.Controllers.Messenger

  get "/", do: render(conn, "index.html")

  get "/webhook", do: Messenger.verify(conn)

  post "/webhook", do: Messenger.recieve_message(conn)

  post "/send_msg", do: Messenger.send_message(conn)

  get "/ping", do: send_resp(conn, 200, "pong")

  match _, do: send_resp(conn, 404, "404!")

  defp render(%{status: status} = conn, template, assigns \\ []) do
    body =
      "lib/chatbot/templates"
      |> Path.join(template)
      |> String.replace_suffix(".html", ".html.eex")
      |> EEx.eval_file(assigns)

    send_resp(conn, status || 200, body)
  end
end