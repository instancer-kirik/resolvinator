defmodule ResolvinatorWeb.TopicLive.Index do
  use ResolvinatorWeb, :live_view
  
  alias Resolvinator.Content
  alias Resolvinator.Content.Topic

  @impl true
  def mount(_params, _session, socket) do
    if connected?(socket), do: Content.subscribe()
    
    {:ok,
     socket
     |> stream(:topics, list_topics())
     |> assign(:selected_topic, nil)
     |> assign(:filter, %{
       category: nil,
       level: nil,
       status: nil,
       is_featured: nil
     })}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Topic")
    |> assign(:topic, Content.get_topic!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Topic")
    |> assign(:topic, %Topic{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Topics")
    |> assign(:topic, nil)
  end

  @impl true
  def handle_event("filter", %{"filter" => filter}, socket) do
    {:noreply,
     socket
     |> assign(:filter, Map.merge(socket.assigns.filter, filter))
     |> assign(:topics, list_topics(socket.assigns.filter))}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    topic = Content.get_topic!(id)
    {:ok, _} = Content.delete_topic(topic)

    {:noreply, stream_delete(socket, :topics, topic)}
  end

  defp list_topics(filter \\ %{}) do
    Content.list_topics()
    |> Enum.filter(&matches_filter?(&1, filter))
    |> Enum.sort_by(&{&1.position, &1.name})
  end

  defp matches_filter?(topic, filter) do
    Enum.all?(filter, fn
      {_, nil} -> true
      {"category", value} -> topic.category == value
      {"level", value} -> topic.level == value
      {"status", value} -> topic.status == value
      {"is_featured", value} -> topic.is_featured == value
      _ -> true
    end)
  end
end 