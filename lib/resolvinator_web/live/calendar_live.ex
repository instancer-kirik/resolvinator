defmodule ResolvinatorWeb.CalendarLive do
  use ResolvinatorWeb, :live_view
  alias Resolvinator.Calendar
  alias TimeTrackerWeb.CalendarLive.CalendarComponent

  @impl true
  def mount(_params, session, socket) do
    case session do
      %{"user_id" => user_id} ->
        today = Date.utc_today()
        calendar_system = Calendar.get_default_calendar_system(user_id)

        calendar_data = Calendar.get_month_data(
          user_id,
          today.year,
          today.month,
          calendar_system.id
        )

        {:ok,
         assign(socket,
           user_id: user_id,
           year: today.year,
           month: today.month,
           calendar_system: calendar_system,
           calendar_data: calendar_data
         )}

      _ ->
        {:ok,
         socket
         |> put_flash(:error, "You must be logged in to access this page")
         |> redirect(to: ~p"/")}
    end
  end

  @impl true
  def handle_event("change_month", %{"month" => month, "year" => year}, socket) do
    {month, _} = Integer.parse(month)
    {year, _} = Integer.parse(year)

    calendar_data = Calendar.get_month_data(
      socket.assigns.user_id,
      year,
      month,
      socket.assigns.calendar_system.id
    )

    {:noreply,
     assign(socket,
       year: year,
       month: month,
       calendar_data: calendar_data
     )}
  end

  @impl true
  def handle_event("prev_month", _params, socket) do
    {year, month} = case socket.assigns.month - 1 do
      0 -> {socket.assigns.year - 1, 12}
      month -> {socket.assigns.year, month}
    end

    calendar_data = Calendar.get_month_data(
      socket.assigns.user_id,
      year,
      month,
      socket.assigns.calendar_system.id
    )

    {:noreply,
     assign(socket,
       year: year,
       month: month,
       calendar_data: calendar_data
     )}
  end

  @impl true
  def handle_event("next_month", _params, socket) do
    {year, month} = case socket.assigns.month + 1 do
      13 -> {socket.assigns.year + 1, 1}
      month -> {socket.assigns.year, month}
    end

    calendar_data = Calendar.get_month_data(
      socket.assigns.user_id,
      year,
      month,
      socket.assigns.calendar_system.id
    )

    {:noreply,
     assign(socket,
       year: year,
       month: month,
       calendar_data: calendar_data
     )}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="max-w-7xl mx-auto p-6">
      <div class="flex justify-between items-center mb-8">
        <h1 class="text-3xl font-bold text-gray-900 dark:text-white">Calendar</h1>
        <div class="flex items-center space-x-4">
          <button
            phx-click="prev_month"
            class="px-4 py-2 bg-gray-100 hover:bg-gray-200 rounded-lg"
          >
            Previous
          </button>
          <select
            phx-change="change_month"
            name="month"
            class="px-4 py-2 bg-gray-100 rounded-lg"
          >
            <%= for {name, num} <- month_options() do %>
              <option value={num} selected={@month == num}><%= name %></option>
            <% end %>
          </select>
          <select
            phx-change="change_month"
            name="year"
            class="px-4 py-2 bg-gray-100 rounded-lg"
          >
            <%= for year <- (@year - 5)..(@year + 5) do %>
              <option value={year} selected={@year == year}><%= year %></option>
            <% end %>
          </select>
          <button
            phx-click="next_month"
            class="px-4 py-2 bg-gray-100 hover:bg-gray-200 rounded-lg"
          >
            Next
          </button>
        </div>
      </div>

      <.live_component
        module={CalendarComponent}
        id="calendar"
        year={@year}
        month={@month}
        user={%{id: @user_id}}
        calendar_system={@calendar_data.calendar_system}
        day_datas={@calendar_data.day_data}
        events={@calendar_data.events}
        daily_reminders={@calendar_data.daily_reminders}
      />
    </div>
    """
  end

  defp month_options do
    [
      {"January", 1},
      {"February", 2},
      {"March", 3},
      {"April", 4},
      {"May", 5},
      {"June", 6},
      {"July", 7},
      {"August", 8},
      {"September", 9},
      {"October", 10},
      {"November", 11},
      {"December", 12}
    ]
  end
end
