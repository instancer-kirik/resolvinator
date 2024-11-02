defmodule ResolvinatorWeb.EventChannel do
  use ResolvinatorWeb, :channel
  alias Phoenix.PubSub

  def join("events:global", _payload, socket) do
    {:ok, socket}
  end

  # Broadcast system events
  def broadcast_system_event(event_type, payload) do
    PubSub.broadcast(Resolvinator.PubSub, "events:global", %{
      type: "system_event",
      event: event_type,
      payload: payload
    })
  end

  # Broadcast news
  def broadcast_news(title, message, priority) do
    PubSub.broadcast(Resolvinator.PubSub, "events:global", %{
      type: "news",
      payload: %{
        title: title,
        message: message,
        priority: priority
      }
    })
  end
end 