defmodule ResolvinatorWeb.MessageLive.SearchComponent do
  use ResolvinatorWeb, :live_component

  def render(assigns) do
    ~H"""
    <div class="message-search">
      <form phx-submit="search" phx-target={@myself}>
        <div class="flex gap-4">
          <div class="flex-1">
            <input type="text" 
                   name="query" 
                   value={@query} 
                   placeholder="Search messages..."
                   class="w-full px-3 py-2 border rounded-md"
                   phx-debounce="300" />
          </div>
          
          <div class="flex gap-2">
            <.input type="date" name="from_date" value={@from_date} />
            <.input type="date" name="to_date" value={@to_date} />
          </div>

          <button type="submit" class="px-4 py-2 bg-blue-500 text-white rounded-md">
            Search
          </button>
        </div>
      </form>

      <div class="mt-4">
        <%= for message <- @messages do %>
          <div class="p-4 border-b">
            <div class="flex justify-between">
              <span class="font-semibold">
                <%= message.from_user_id %>
              </span>
              <span class="text-gray-500">
                <%= Calendar.strftime(message.inserted_at, "%Y-%m-%d %H:%M") %>
              </span>
            </div>
            <div class="mt-2">
              <%= message.content %>
            </div>
          </div>
        <% end %>
      </div>
    </div>
    """
  end

  def update(assigns, socket) do
    socket = assign(socket, 
      query: assigns[:query] || "",
      from_date: assigns[:from_date],
      to_date: assigns[:to_date],
      messages: search(assigns)
    )
    
    {:ok, socket}
  end

  def handle_event("search", %{"query" => query} = params, socket) do
    {:noreply, assign(socket,
      query: query,
      from_date: params["from_date"],
      to_date: params["to_date"],
      messages: search(params)
    )}
  end

  defp search(params) do
    Resolvinator.Messages.search_messages(
      query: params["query"],
      from_date: parse_date(params["from_date"]),
      to_date: parse_date(params["to_date"]),
      user_id: params["user_id"],
      limit: 50
    )
  end

  defp parse_date(nil), do: nil
  defp parse_date(""), do: nil
  defp parse_date(date_string) do
    case Date.from_iso8601(date_string) do
      {:ok, date} -> date
      _ -> nil
    end
  end
end 