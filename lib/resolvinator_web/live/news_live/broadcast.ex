defmodule ResolvinatorWeb.NewsLive.Broadcast do
  use ResolvinatorWeb, :live_view
  alias ResolvinatorWeb.EventChannel

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(:form, to_form(%{"title" => "", "message" => "", "priority" => "normal"}))
     |> assign(:notifications, [])}
  end

  @impl true
  def handle_event("broadcast", %{"news" => news_params}, socket) do
    EventChannel.broadcast_news(
      news_params["title"],
      news_params["message"],
      news_params["priority"]
    )

    notifications = [
      %{
        timestamp: NaiveDateTime.local_now(),
        title: news_params["title"],
        priority: news_params["priority"]
      }
      | socket.assigns.notifications
    ]

    {:noreply,
     socket
     |> put_flash(:info, "News broadcast sent successfully")
     |> assign(:notifications, Enum.take(notifications, 10))
     |> assign(:form, to_form(%{"title" => "", "message" => "", "priority" => "normal"}))}
  end

  defp priority_color("urgent"), do: "bg-red-100 text-red-800"
  defp priority_color("high"), do: "bg-orange-100 text-orange-800"
  defp priority_color("normal"), do: "bg-blue-100 text-blue-800"
  defp priority_color("low"), do: "bg-gray-100 text-gray-800"
end
