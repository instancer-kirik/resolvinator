defmodule ResolvinatorWeb.SearchAndRelateComponent do
  use ResolvinatorWeb, :live_component

  alias Resolvinator.Content

  @impl true
  def update(assigns, socket) do

    assigns = Map.merge(%{
      search_query: "",
      results: [],
      selected: nil,
      selected_type: nil,
      loading: false,
      error: nil,
      source: assigns[:source] || socket.assigns[:source]
    }, assigns)


    {:ok, assign(socket, assigns)}
  end

  @impl true
  def handle_event("search", %{"query" => query}, socket) do
    if query == "" do
      {:noreply, assign(socket, results: [], search_query: query, loading: false)}
    else
      send(self(), {:search, query})
      {:noreply, assign(socket, search_query: query, loading: true, error: nil)}
    end
  end

  @impl true
  def handle_event("select_result", %{"id" => id, "type" => type}, socket) do
    case Content.get_associable(type, id) do
      {:ok, selected} ->
        {:noreply, assign(socket, selected: selected, selected_type: type, error: nil)}
      {:error, :not_found} ->
        {:noreply, assign(socket, error: "Record not found")}
      {:error, :invalid_type} ->
        {:noreply, assign(socket, error: "Invalid type")}
    end
  end

  @impl true
  def handle_event("relate_record", %{"related_id" => related_id, "related_type" => related_type}, socket) do

    case Content.get_associable(related_type, related_id) do
      {:ok, related} ->
        source = socket.assigns.source

        case Content.relate_records(source, related) do
          {:ok, _relation} ->
            # Fetch the updated source based on its type
            updated_source =
              case source.__struct__ do
                Resolvinator.Content.Problem -> Content.get_problem_with_visible_descriptions!(source.id, socket.assigns.current_user.id)
                Resolvinator.Content.Solution -> Content.get_solution_with_visible_descriptions!(source.id, socket.assigns.current_user.id)
                Resolvinator.Content.Advantage -> Content.get_advantage_with_visible_descriptions!(source.id, socket.assigns.current_user.id)
                Resolvinator.Content.Lesson -> Content.get_lesson_with_visible_descriptions!(source.id, socket.assigns.current_user.id)
              end

            # Notify parent LiveView to update its state
            send(self(), {:update_source, updated_source})
            {:noreply, assign(socket, selected: nil, error: nil, source: updated_source)}
          {:error, reason} ->

            {:noreply, assign(socket, error: reason)}
        end
      {:error, :not_found} ->
      
        {:noreply, assign(socket, error: "Related record not found")}
      {:error, :invalid_id} ->

        {:noreply, assign(socket, error: "Invalid related ID format")}
    end
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <form phx-debounce="500" phx-change="search" phx-target={@myself}>
        <input type="text" name="query" placeholder="Search..." value={@search_query} />
      </form>

      <%= if @loading do %>
        <p>Loading...</p>
      <% else %>
        <ul>
          <%= for {name, id, type} <- @results do %>
            <li>
              <button phx-click="select_result" phx-value-id={id} phx-value-type={type} phx-target={@myself}>
                <%= name %>
              </button>
            </li>
          <% end %>
        </ul>
      <% end %>

      <%= if @selected do %>
        <div>
          <h3>Selected: <%= if @selected.__struct__ == Resolvinator.Content.Description, do: @selected.text, else: @selected.name %></h3>
          <button phx-click="relate_record" phx-value-related_id={@selected.id} phx-value-related_type={@selected_type} phx-target={@myself}>
            Relate
          </button>
        </div>
      <% end %>

      <%= if @error do %>
        <div class="error"><%= @error %></div>
      <% end %>
    </div>
    """
  end
end
