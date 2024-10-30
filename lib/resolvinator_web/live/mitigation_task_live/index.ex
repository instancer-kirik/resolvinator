defmodule ResolvinatorWeb.MitigationTaskLive.Index do
  use ResolvinatorWeb, :live_view

  alias Resolvinator.Risks
  alias Resolvinator.Risks.MitigationTask

  @impl true
  def mount(_params, _session, socket) do
    {:ok, stream(socket, :mitigation_tasks, Risks.list_mitigation_tasks())}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Mitigation task")
    |> assign(:mitigation_task, Risks.get_mitigation_task!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Mitigation task")
    |> assign(:mitigation_task, %MitigationTask{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Mitigation tasks")
    |> assign(:mitigation_task, nil)
  end

  @impl true
  def handle_info({ResolvinatorWeb.MitigationTaskLive.FormComponent, {:saved, mitigation_task}}, socket) do
    {:noreply, stream_insert(socket, :mitigation_tasks, mitigation_task)}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    mitigation_task = Risks.get_mitigation_task!(id)
    {:ok, _} = Risks.delete_mitigation_task(mitigation_task)

    {:noreply, stream_delete(socket, :mitigation_tasks, mitigation_task)}
  end
end
