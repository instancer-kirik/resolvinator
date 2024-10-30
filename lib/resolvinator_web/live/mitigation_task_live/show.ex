defmodule ResolvinatorWeb.MitigationTaskLive.Show do
  use ResolvinatorWeb, :live_view

  alias Resolvinator.Risks

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:mitigation_task, Risks.get_mitigation_task!(id))}
  end

  defp page_title(:show), do: "Show Mitigation task"
  defp page_title(:edit), do: "Edit Mitigation task"
end
