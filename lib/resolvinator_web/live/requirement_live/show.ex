defmodule ResolvinatorWeb.RequirementLive.Show do
  use ResolvinatorWeb, :live_view

  alias Resolvinator.Requirements

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:requirement, Requirements.get_requirement!(id))}
  end

  defp page_title(:show), do: "Show Requirement"
  defp page_title(:edit), do: "Edit Requirement"
end
