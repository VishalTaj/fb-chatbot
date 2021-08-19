defmodule Chatbot.Services.Survey do
  @moduledoc false

  # def surveys(survey, params) do
  #   apply(Chatbot.Services.Survey, survey, params)
  # end


  def get_questions(id, message) do
    if !Map.has_key?(message, "quick_reply") do
      Chatbot.Services.Messenger.quick_replies(id, q1(), "search books by name or by ID?")
    end
  end

  def q1() do
    [
      %{
        content_type: "text",
        title: "By Id",
        payload: "{}",
      }, %{
        content_type: "text",
        title: "By name",
        payload: "{}",
      }
    ]
  end

  def search_by_name(id) do
    Chatbot.Services.Messenger.quick_replies(id, q1(), "")
  end

  def search_by_id(id) do
    Chatbot.Services.Messenger.quick_replies(id, q1(), "")
  end
end