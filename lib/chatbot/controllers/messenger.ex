defmodule Chatbot.Controllers.Messenger do
  @moduledoc false

  alias Chatbot.Controllers.Base
  alias Chatbot.Services.Survey

  @doc """
    Facebook Triggers this webhook based on Messenger Subscription
  """
  def recieve_message(conn) do
    %{"entry" => entries} = conn.body_params
    IO.inspect(entries)
    Enum.each(entries, fn entry ->
      event = Map.get(entry, "messaging") |> Enum.at(0)
      %{"message" => message, "sender" => %{"id" => id}} = event
      Survey.get_questions(id, message)
    end)


    Base.render_json(conn, 200, "EVENT_RECEIVED")
  end

  @doc """
    This action will send message to the Facebook App
  """
  def send_message(conn) do
    %{"psid" => id, "message" => message} = conn.body_params
    {:ok, response} = Chatbot.Services.Messenger.send_message(id, message)
    resp_body = Jason.encode!(response.body)
    Base.render_json(conn, response.status_code || 200, resp_body)
  end

  @doc """
    This action will take care of verifying the domain with Facebook App
  """
  def verify(conn) do
    verify_token = System.get_env("TOKEN")
    %{"hub.mode" => mode, "hub.verify_token" => token, "hub.challenge" => challenge} = conn.query_params

    if (mode == "subscribe" and token == verify_token) do
      IO.inspect("Webhook verified")
      Base.render_string(conn, 200, challenge)
    else
      IO.inspect("Unauthorized echo")
      Base.render_string(conn, 403, "Unauthorized")
    end
  end
end