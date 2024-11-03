defmodule ResolvinatorWeb.ResourceLive.Index do
  use ResolvinatorWeb, :live_view

  alias Resolvinator.Resources
  alias Resolvinator.Resources.Resource

  @impl true
  def mount(_params, _session, socket) do
    {:ok, stream(socket, :resources, Resources.list_resources())}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Resource")
    |> assign(:resource, Resources.get_resource!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Resource")
    |> assign(:resource, %Resource{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Resources")
    |> assign(:resource, nil)
  end

  @impl true
  def handle_info({ResolvinatorWeb.ResourceLive.FormComponent, {:saved, resource}}, socket) do
    {:noreply, stream_insert(socket, :resources, resource)}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    resource = Resources.get_resource!(id)
    {:ok, _} = Resources.delete_resource(resource)

    {:noreply, stream_delete(socket, :resources, resource)}
  end
end
