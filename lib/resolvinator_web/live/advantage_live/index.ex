defmodule ResolvinatorWeb.AdvantageLive.Index do
  use ResolvinatorWeb, :live_view

  alias Resolvinator.Content
  alias Resolvinator.Content.Advantage

  @impl true
  def mount(_params, _session, socket) do
    {:ok, stream(socket, :advantages, Content.list_advantages())}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Advantage")
    |> assign(:advantage, Content.get_advantage!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Advantage")
    |> assign(:advantage, %Advantage{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Advantages")
    |> assign(:advantage, nil)
  end

  @impl true
  def handle_info({ResolvinatorWeb.AdvantageLive.FormComponent, {:saved, advantage}}, socket) do
    {:noreply, stream_insert(socket, :advantages, advantage)}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    advantage = Content.get_advantage!(id)
    {:ok, _} = Content.delete_advantage(advantage)

    {:noreply, stream_delete(socket, :advantages, advantage)}
  end
end
