defmodule ResolvinatorWeb.ImpactLive.Index do
  use ResolvinatorWeb, :live_view

  alias Resolvinator.Risks
  alias Resolvinator.Risks.Impact

  @impl true
  def mount(%{"risk_id" => risk_id} = _params, _session, socket) do
    {:ok, 
     socket
     |> assign(:risk_id, risk_id)
     |> stream(:impacts, Risks.list_impacts(risk_id))}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Impact")
    |> assign(:impact, Risks.get_impact!(socket.assigns.risk_id, id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Impact")
    |> assign(:impact, %Impact{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Impacts")
    |> assign(:impact, nil)
  end

  @impl true
  def handle_info({ResolvinatorWeb.ImpactLive.FormComponent, {:saved, impact}}, socket) do
    {:noreply, stream_insert(socket, :impacts, impact)}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    impact = Risks.get_impact!(socket.assigns.risk_id, id)
    {:ok, _} = Risks.delete_impact(impact)

    {:noreply, stream_delete(socket, :impacts, impact)}
  end
end
