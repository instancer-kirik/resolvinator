defmodule ResolvinatorWeb.AdvantageLive.Show do
  use ResolvinatorWeb, :live_view

  alias Resolvinator.Content
  alias Resolvinator.Accounts

  on_mount {ResolvinatorWeb.UserAuth, :mount_current_user}

  @impl true
  def mount(_params, %{"user_token" => user_token}, socket) do
    case Accounts.get_user_by_session_token(user_token) do
      nil -> {:error, "User not found"}
      user ->
        socket = assign(socket, :current_user, user)
        {:ok, assign(socket, search_query: "", results: [], selected: nil, loading: false, error: nil, source: nil, source_type: "advantage")}
    end
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do


    user_id = socket.assigns.current_user.id
    advantage = Content.get_advantage_with_visible_descriptions!(id, user_id)

    hidden_description_ids = Content.get_hidden_description_ids(user_id)

    updated_descriptions = Enum.map(advantage.descriptions, fn description ->
      Map.put(description, :hidden, description.id in hidden_description_ids)
    end)

    updated_advantage = Map.put(advantage, :descriptions, updated_descriptions)
    
    {:noreply, assign(socket, page_title: page_title(socket.assigns.live_action), advantage: updated_advantage, source: updated_advantage, source_type: "advantage")}
  end


  @impl true
  def handle_event("hide-description", %{"id" => id}, socket) do
    user_id = socket.assigns.current_user.id
    description_id = String.to_integer(id)

    Content.hide_description(user_id, description_id)

    updated_descriptions =
      Enum.map(socket.assigns.advantage.descriptions, fn description ->
        if description.id == description_id do
          Map.put(description, :hidden, true)
        else
          description
        end
      end)

    updated_advantage = Map.put(socket.assigns.advantage, :descriptions, updated_descriptions)

    {:noreply, assign(socket, :advantage, updated_advantage)}
  end

  @impl true
  def handle_event("unhide-description", %{"id" => id}, socket) do
    user_id = socket.assigns.current_user.id
    description_id = String.to_integer(id)

    Content.unhide_description(user_id, description_id)

    updated_descriptions =
      Enum.map(socket.assigns.advantage.descriptions, fn description ->
        if description.id == description_id do
          Map.put(description, :hidden, false)
        else
          description
        end
      end)

    updated_advantage = Map.put(socket.assigns.advantage, :descriptions, updated_descriptions)

    {:noreply, assign(socket, :advantage, updated_advantage)}
  end

  @impl true
  def handle_info({:update_source, updated_source}, socket) do
    hidden_description_ids = Content.get_hidden_description_ids(socket.assigns.current_user.id)

    updated_descriptions = Enum.map(updated_source.descriptions, fn description ->
      Map.put(description, :hidden, description.id in hidden_description_ids)
    end)

    updated_source = Map.put(updated_source, :descriptions, updated_descriptions)

    {:noreply, assign(socket, source: updated_source, advantage: updated_source)}
  end

  @impl true
  def handle_info({:search, query}, socket) do
    results = Content.searchAll(query, socket.assigns.current_user.id)
    {:noreply, assign(socket, results: results, loading: false)}
  end

  @impl true
  def handle_info({ResolvinatorWeb.AdvantageLive.FormComponent, {:saved, advantage}}, socket) do
    {:noreply,
     socket
     |> put_flash(:info, "Advantage updated successfully")
     |> push_patch(to: ~p"/advantages/#{advantage}")}
  end

  @impl true
  def handle_info(_message, socket) do
    {:noreply, socket}
  end

  defp page_title(:show), do: "Show Advantage"
  defp page_title(:edit), do: "Edit Advantage"
end
