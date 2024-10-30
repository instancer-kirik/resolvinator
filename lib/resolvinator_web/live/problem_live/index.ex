defmodule ResolvinatorWeb.ProblemLive.Index do
  use ResolvinatorWeb, :live_view

  alias Resolvinator.Content
  alias Resolvinator.Content.Problem

  on_mount {ResolvinatorWeb.UserAuth, :mount_current_user}

  @impl true
  def mount(_params, _session, socket) do
    if socket.assigns.current_user do
      {:ok, stream(socket, :problems, Content.list_problems())}
    else
      {:ok, redirect(socket, to: ~p"/users/log_in")}
    end
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Problem")
    |> assign(:problem, Content.get_problem!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Problem")
    |> assign(:problem, %Problem{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Problems")
    |> assign(:problem, nil)
  end

  @impl true
  def handle_info({ResolvinatorWeb.ProblemLive.FormComponent, {:saved, problem}}, socket) do
    {:noreply, stream_insert(socket, :problems, problem)}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    problem = Content.get_problem!(id)
    {:ok, _} = Content.delete_problem(problem)

    {:noreply, stream_delete(socket, :problems, problem)}
  end
end
