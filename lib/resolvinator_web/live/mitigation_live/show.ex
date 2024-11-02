defmodule ResolvinatorWeb.MitigationLive.Show do
  use ResolvinatorWeb, :live_view

  alias Resolvinator.Risks

  @impl true
  def mount(%{"risk_id" => risk_id}, _session, socket) do
    {:ok, assign(socket, :risk_id, risk_id)}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:mitigation, Risks.get_mitigation!(id))}
  end

  defp page_title(:show), do: "Show Mitigation"
  defp page_title(:edit), do: "Edit Mitigation"
end
