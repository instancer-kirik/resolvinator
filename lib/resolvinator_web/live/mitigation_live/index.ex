defmodule ResolvinatorWeb.MitigationLive.Index do
  use ResolvinatorWeb, :live_view

  alias Resolvinator.Risks
  alias Resolvinator.Risks.Mitigation

  @impl true
  def mount(_params, _session, socket) do
    {:ok, stream(socket, :mitigations, Risks.list_mitigations())}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Mitigation")
    |> assign(:mitigation, Risks.get_mitigation!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Mitigation")
    |> assign(:mitigation, %Mitigation{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Mitigations")
    |> assign(:mitigation, nil)
  end

  @impl true
  def handle_info({ResolvinatorWeb.MitigationLive.FormComponent, {:saved, mitigation}}, socket) do
    {:noreply, stream_insert(socket, :mitigations, mitigation)}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    mitigation = Risks.get_mitigation!(id)
    {:ok, _} = Risks.delete_mitigation(mitigation)

    {:noreply, stream_delete(socket, :mitigations, mitigation)}
  end
end
