defmodule Chatbot.Services.Profile do
  @moduledoc false
  
  @persona System.get_env("PERSONA")
  
  @fb_url %{
    profile: "https://graph.facebook.com/v2.6/me/messenger_profile?access_token=?#{System.get_env("PAGE_ACCESS_TOKEN")}"
  }

  def set_greetings(profile_id) do
    body = %{
      get_started: %{ payload: "" }
    }

  end
end