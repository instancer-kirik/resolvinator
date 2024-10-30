defmodule ResolvinatorWeb.ActorLive.Show do
  use ResolvinatorWeb, :live_view

  alias Resolvinator.Actors

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:actor, Actors.get_actor!(id))}
  end

  defp page_title(:show), do: "Show Actor"
  defp page_title(:edit), do: "Edit Actor"
end
