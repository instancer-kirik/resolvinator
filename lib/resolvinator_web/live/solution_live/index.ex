defmodule ResolvinatorWeb.SolutionLive.Index do
  use ResolvinatorWeb, :live_view

  alias Resolvinator.Content
  alias Resolvinator.Content.Solution

  @impl true
  def mount(_params, _session, socket) do
    solutions = Content.list_solutions()
    {:ok, assign(socket, :solutions, solutions)}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Solution")
    |> assign(:solution, Content.get_solution!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Solution")
    |> assign(:solution, %Solution{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Solutions")
    |> assign(:solution, nil)
  end

  @impl true
  def handle_info({ResolvinatorWeb.SolutionLive.FormComponent, {:saved, solution}}, socket) do
    {:noreply, stream_insert(socket, :solutions, solution)}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    solution = Content.get_solution!(id)
    {:ok, _} = Content.delete_solution(solution)

    {:noreply, stream_delete(socket, :solutions, solution)}
  end
end
