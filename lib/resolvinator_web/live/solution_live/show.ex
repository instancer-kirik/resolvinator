defmodule ResolvinatorWeb.SolutionLive.Show do
  use ResolvinatorWeb, :live_view

  alias Resolvinator.Content
  alias Resolvinator.Acts

  on_mount {ResolvinatorWeb.UserAuth, :mount_current_user}

  @impl true
  def mount(_params, %{"user_token" => user_token}, socket) do
    case Accounts.get_user_by_session_token(user_token) do
      nil -> {:error, "User not found"}
      user ->
        socket = assign(socket, :current_user, user)
        {:ok, assign(socket, search_query: "", results: [], selected: nil, loading: false, error: nil, source: nil, source_type: "solution")}
    end
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do

    user_id = socket.assigns.current_user.id
    solution = Content.get_solution_with_visible_descriptions!(id, user_id)

    hidden_description_ids = Content.get_hidden_description_ids(user_id)

    updated_descriptions = Enum.map(solution.descriptions, fn description ->
      Map.put(description, :hidden, description.id in hidden_description_ids)
    end)

    updated_solution = Map.put(solution, :descriptions, updated_descriptions)
   
    {:noreply, assign(socket, page_title: page_title(socket.assigns.live_action), solution: updated_solution, source: updated_solution, source_type: "solution")}
  end

  @impl true
  def handle_info({:update_source, updated_source}, socket) do
    hidden_description_ids = Content.get_hidden_description_ids(socket.assigns.current_user.id)

    updated_descriptions = Enum.map(updated_source.descriptions, fn description ->
      Map.put(description, :hidden, description.id in hidden_description_ids)
    end)

    updated_source = Map.put(updated_source, :descriptions, updated_descriptions)

    {:noreply, assign(socket, source: updated_source, solution: updated_source)}
  end
  @impl true
  def handle_info({:search, query}, socket) do
    results = Content.searchAll(query, socket.assigns.current_user.id)
    {:noreply, assign(socket, results: results, loading: false)}
  end

  @impl true
  def handle_event("hide-description", %{"id" => id}, socket) do
    user_id = socket.assigns.current_user.id
    description_id = String.to_integer(id)

    Content.hide_description(user_id, description_id)

    updated_descriptions =
      Enum.map(socket.assigns.solution.descriptions, fn description ->
        if description.id == description_id do
          Map.put(description, :hidden, true)
        else
          description
        end
      end)

    updated_solution = Map.put(socket.assigns.solution, :descriptions, updated_descriptions)

    {:noreply, assign(socket, :solution, updated_solution)}
  end

  @impl true
  def handle_event("unhide-description", %{"id" => id}, socket) do
    user_id = socket.assigns.current_user.id
    description_id = String.to_integer(id)

    Content.unhide_description(user_id, description_id)

    updated_descriptions =
      Enum.map(socket.assigns.solution.descriptions, fn description ->
        if description.id == description_id do
          Map.put(description, :hidden, false)
        else
          description
        end
      end)

    updated_solution = Map.put(socket.assigns.solution, :descriptions, updated_descriptions)

    {:noreply, assign(socket, :solution, updated_solution)}
  end

  
  defp page_title(:show), do: "Show Solution"
  defp page_title(:edit), do: "Edit Solution"
end
