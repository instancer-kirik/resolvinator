defmodule ResolvinatorWeb.Components.EntitySearchComponent do
  use ResolvinatorWeb, :live_component
  alias Resolvinator.Accounts
  alias Resolvinator.Projects

  @impl true
  def render(assigns) do
    ~H"""
    <div class="entity-search relative" id={@id}>
      <div class="flex gap-2 items-center">
        <div class="relative flex-1">
          <input type="text"
                 id={"#{@id}-input"}
                 phx-target={@myself}
                 phx-keyup="search"
                 phx-debounce="300"
                 phx-click="show_results"
                 value={@query}
                 placeholder={@placeholder}
                 class="w-full px-3 py-2 border rounded-md pr-10"
                 autocomplete="off" />
          
          <div :if={@loading} class="absolute right-3 top-2.5">
            <.icon name="hero-arrow-path" class="h-5 w-5 animate-spin text-gray-400" />
          </div>
        </div>

        <%= if @selected do %>
          <button type="button" 
                  phx-click="clear" 
                  phx-target={@myself}
                  class="text-gray-400 hover:text-gray-600">
            <.icon name="hero-x-mark" class="h-5 w-5" />
          </button>
        <% end %>
      </div>

      <%= if @show_results and not @selected do %>
        <div class="absolute z-50 w-full mt-1 bg-white rounded-md shadow-lg border max-h-64 overflow-y-auto">
          <%= if Enum.empty?(@results) do %>
            <div class="px-4 py-2 text-sm text-gray-500">
              No results found
            </div>
          <% else %>
            <div class="py-1">
              <%= for result <- @results do %>
                <button type="button"
                        phx-click="select"
                        phx-value-id={result.id}
                        phx-target={@myself}
                        class="w-full text-left px-4 py-2 text-sm hover:bg-gray-100 flex items-center gap-2">
                  <%= case @type do %>
                    <% :user -> %>
                      <.icon name="hero-user-circle" class="h-5 w-5 text-gray-400" />
                      <div>
                        <div class="font-medium"><%= result.email %></div>
                        <div class="text-xs text-gray-500">
                          <%= if result.last_active, do: "Last active #{relative_time(result.last_active)}" %>
                        </div>
                      </div>
                    <% :project -> %>
                      <.icon name="hero-folder" class="h-5 w-5 text-gray-400" />
                      <div>
                        <div class="font-medium"><%= result.name %></div>
                        <div class="text-xs text-gray-500">
                          <%= result.description |> String.slice(0..50) %><%= if String.length(result.description) > 50, do: "..." %>
                        </div>
                      </div>
                  <% end %>
                </button>
              <% end %>
            </div>
          <% end %>
        </div>
      <% end %>
    </div>
    """
  end

  @impl true
  def mount(socket) do
    {:ok,
     socket
     |> assign(:query, "")
     |> assign(:results, [])
     |> assign(:selected, nil)
     |> assign(:show_results, false)
     |> assign(:loading, false)}
  end

  @impl true
  def update(%{type: type} = assigns, socket) do
    {:ok,
     socket
     |> assign(assigns)
     |> assign(:type, type)
     |> assign(:placeholder, placeholder_for_type(type))}
  end

  @impl true
  def handle_event("search", %{"value" => query}, socket) do
    send(self(), {:search, query})

    {:noreply,
     socket
     |> assign(:query, query)
     |> assign(:loading, true)
     |> assign(:show_results, true)}
  end

  def handle_event("show_results", _, socket) do
    {:noreply, assign(socket, :show_results, true)}
  end

  def handle_event("select", %{"id" => id}, socket) do
    selected = find_entity(String.to_integer(id), socket.assigns.type)
    send(self(), {:selected, selected})

    {:noreply,
     socket
     |> assign(:selected, selected)
     |> assign(:show_results, false)
     |> assign(:query, display_name(selected, socket.assigns.type))}
  end

  def handle_event("clear", _, socket) do
    send(self(), {:selected, nil})

    {:noreply,
     socket
     |> assign(:selected, nil)
     |> assign(:query, "")
     |> assign(:show_results, false)}
  end

  @impl true
  def handle_info({:search_results, results}, socket) do
    {:noreply,
     socket
     |> assign(:results, results)
     |> assign(:loading, false)}
  end

  defp find_entity(id, :user), do: Accounts.get_user!(id)
  defp find_entity(id, :project), do: Projects.get_project!(id)

  defp display_name(entity, :user), do: entity.email
  defp display_name(entity, :project), do: entity.name

  defp placeholder_for_type(:user), do: "Search users..."
  defp placeholder_for_type(:project), do: "Search projects..."

  defp relative_time(_datetime) do
    # Implementation or placeholder
    "some time ago"
  end
end 