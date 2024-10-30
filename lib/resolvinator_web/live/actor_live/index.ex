defmodule ResolvinatorWeb.ActorLive.Index do
  use ResolvinatorWeb, :live_view

  alias Resolvinator.Actors
  alias Resolvinator.Actors.Actor

  @impl true
  def mount(_params, _session, socket) do
    {:ok, stream(socket, :actors, Actors.list_actors())}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Actor")
    |> assign(:actor, Actors.get_actor!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Actor")
    |> assign(:actor, %Actor{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Actors")
    |> assign(:actor, nil)
  end

  @impl true
  def handle_info({ResolvinatorWeb.ActorLive.FormComponent, {:saved, actor}}, socket) do
    {:noreply, stream_insert(socket, :actors, actor)}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    actor = Actors.get_actor!(id)
    {:ok, _} = Actors.delete_actor(actor)

    {:noreply, stream_delete(socket, :actors, actor)}
  end
end
