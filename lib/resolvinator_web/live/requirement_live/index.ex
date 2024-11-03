defmodule ResolvinatorWeb.RequirementLive.Index do
  use ResolvinatorWeb, :live_view

  alias Resolvinator.Requirements
  alias Resolvinator.Requirements.Requirement

  @impl true
  def mount(_params, _session, socket) do
    {:ok, stream(socket, :requirements, Requirements.list_requirements())}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Requirement")
    |> assign(:requirement, Requirements.get_requirement!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Requirement")
    |> assign(:requirement, %Requirement{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Requirements")
    |> assign(:requirement, nil)
  end

  @impl true
  def handle_info({ResolvinatorWeb.RequirementLive.FormComponent, {:saved, requirement}}, socket) do
    {:noreply, stream_insert(socket, :requirements, requirement)}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    requirement = Requirements.get_requirement!(id)
    {:ok, _} = Requirements.delete_requirement(requirement)

    {:noreply, stream_delete(socket, :requirements, requirement)}
  end
end
