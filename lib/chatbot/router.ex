defmodule Chatbot.Router do
  use Plug.Router

  plug(Plug.Parsers,
    parsers: [:json],
    pass: ["text/*"],
    json_decoder: Jason
  )

  plug(:match)
  plug(:dispatch)

  get "/" do
    render(conn, "index.html")
  end

  post "/webhook" do
    IO.inspect(conn.body_params)
    %{"entry" => entries} = conn.body_params

    Enum.each(entries, fn entry ->
      event = Map.get(entry, "messaging") |> Enum.at(0)
      IO.inspect(event)
      %{"message" => %{"text" => text}, "sender" => %{"id" => id}} = event
    end)

    send_resp(conn, 200, "EVENT_RECEIVED")
  end

  get "/webhook" do
    verify_token = System.get_env("TOKEN")
    %{"hub.mode" => mode, "hub.verify_token" => token, "hub.challenge" => challenge} = conn.query_params
    if (mode == "subscribe" and token == verify_token) do
      IO.inspect("Webhook verified")
      send_resp(conn, 200, challenge)
    else
      send_resp(conn, 403, "Unauthorized")
    end
  end

  post "/send_msg" do
    %{"psid" => id, "message" => message} = conn.body_params
    url = "https://graph.facebook.com/v2.6/me/messages?access_token=#{System.get_env("PAGE_ACCESS_TOKEN")}"
    body = %{recipient: %{id: id}, message: %{text: message}, persona_id: System.get_env("PERSONA")}
    headers = [{"Content-type", "application/json"}]
    {:ok, response} = HTTPoison.post(url, Jason.encode!(body), headers)
    resp_body = Jason.encode!(response.body)
    send_resp(conn, response.status_code || 200, resp_body)
  end

  post "/send_card" do
    %{"psid" => psid, "entry" => entry} = conn.body_params
    url = "https://graph.facebook.com/v2.6/me/messages?access_token=#{System.get_env("PAGE_ACCESS_TOKEN")}"
    body = %{
      recipient: %{id: psid},
      message: %{
        attachment: %{
          type: "template",
          payload: %{
            template_type: "generic",
            elements: [
              %{
                title: entry.title,
                image_url: entry.image,
                subtitle: "",
                default_action: %{
                  type: "web_url",
                  url: entry.url,
                  messenger_extensions: false,
                  webview_height_ratio: "full"
                }
              }
            ]
          }
        }
      }
    }
    headers = [{"Content-type", "application/json"}]
    {:ok, response} = HTTPoison.post(url, Jason.encode!(body), headers)
    resp_body = Jason.encode!(response.body)
    send_resp(conn, response.status_code || 200, resp_body)
  end

  get "/ping" do
    send_resp(conn, 200, "pong")
  end

  match _ do
    send_resp(conn, 404, "404!")
  end

  defp render(%{status: status} = conn, template, assigns \\ []) do
    body =
      "lib/chatbot/templates"
      |> Path.join(template)
      |> String.replace_suffix(".html", ".html.eex")
      |> EEx.eval_file(assigns)

    send_resp(conn, status || 200, body)
  end

  defp render_json(%{status: status} = conn, data) do
    body = Jason.encode!(data)
    send_resp(conn, status || 200, body)
  end
end