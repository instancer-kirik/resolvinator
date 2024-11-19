defmodule ResolvinatorWeb.CalendarLive do
  use ResolvinatorWeb, :live_view
  alias Resolvinator.Calendar

  @impl true
  def mount(_params, session, socket) do
    case session do
      %{"user_id" => user_id} ->
        {:ok,
         assign(socket,
           uploaded_files: [],
           error_message: nil,
           success_message: nil,
           user_id: user_id
         )}

      _ ->
        {:ok,
         socket
         |> put_flash(:error, "You must be logged in to access this page")
         |> redirect(to: ~p"/")}
    end
  end

  @impl true
  def handle_event("validate", _params, socket) do
    {:noreply, socket}
  end

  @impl true
  def handle_event("save", _params, socket) do
    consume_uploaded_entries(socket, :calendar, fn %{path: path}, _entry ->
      case Calendar.process_ics_file(path, socket.assigns.user_id) do
        {:ok, events} ->
          {:ok, %{count: length(events)}}
        {:error, reason} ->
          {:error, reason}
      end
    end)
    |> case do
      [{:ok, %{count: count}}] ->
        {:noreply,
         socket
         |> put_flash(:info, "Successfully imported #{count} events to TimeTracker!")
         |> assign(success_message: "Events have been added to your calendar.", error_message: nil)}

      [{:error, reason}] ->
        {:noreply,
         socket
         |> put_flash(:error, "Failed to import events: #{inspect(reason)}")
         |> assign(error_message: "Failed to process calendar file.", success_message: nil)}
    end
  end

  @impl true
  def handle_event("process-ics", %{"ics" => %{"content" => content}}, socket) do
    case Calendar.process_ics_content(content, socket.assigns.user_id) do
      {:ok, events} ->
        {:noreply,
         socket
         |> put_flash(:info, "Successfully imported #{length(events)} events!")
         |> assign(success_message: "Events have been added to your calendar.", error_message: nil)}

      {:error, reason} ->
        {:noreply,
         socket
         |> put_flash(:error, "Failed to import events: #{inspect(reason)}")
         |> assign(error_message: "Failed to process calendar content.", success_message: nil)}
    end
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="max-w-2xl mx-auto p-6">
      <h1 class="text-3xl font-bold mb-8 text-gray-900 dark:text-white">Calendar Import</h1>

      <div class="mb-8">
        <h2 class="text-xl font-semibold mb-4 text-gray-800 dark:text-gray-200">Upload ICS File</h2>
        <form phx-submit="save" phx-change="validate">
          <div class="flex items-center justify-center w-full">
            <label class="flex flex-col items-center justify-center w-full h-64 border-2 border-gray-300 border-dashed rounded-lg cursor-pointer bg-gray-50 dark:hover:bg-gray-800 dark:bg-gray-700 hover:bg-gray-100 dark:border-gray-600 dark:hover:border-gray-500">
              <div class="flex flex-col items-center justify-center pt-5 pb-6">
                <svg class="w-8 h-8 mb-4 text-gray-500 dark:text-gray-400" aria-hidden="true" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 20 16">
                  <path stroke="currentColor" stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M13 13h3a3 3 0 0 0 0-6h-.025A5.56 5.56 0 0 0 16 6.5 5.5 5.5 0 0 0 5.207 5.021C5.137 5.017 5.071 5 5 5a4 4 0 0 0 0 8h2.167M10 15V6m0 0L8 8m2-2 2 2"/>
                </svg>
                <p class="mb-2 text-sm text-gray-500 dark:text-gray-400"><span class="font-semibold">Click to upload</span> or drag and drop</p>
                <p class="text-xs text-gray-500 dark:text-gray-400">ICS files only</p>
              </div>
              <input type="file" class="hidden" accept=".ics" phx-hook="FileUpload" />
            </label>
          </div>
        </form>
      </div>

      <div class="mb-8">
        <h2 class="text-xl font-semibold mb-4 text-gray-800 dark:text-gray-200">Paste ICS Content</h2>
        <form phx-submit="process-ics">
          <div class="space-y-4">
            <div>
              <textarea
                name="ics[content]"
                rows="6"
                class="block w-full rounded-md border-gray-300 shadow-sm focus:border-indigo-500 focus:ring-indigo-500 dark:bg-gray-800 dark:border-gray-600"
                placeholder="Paste your ICS content here..."
              ></textarea>
            </div>
            <button type="submit" class="w-full flex justify-center py-2 px-4 border border-transparent rounded-md shadow-sm text-sm font-medium text-white bg-indigo-600 hover:bg-indigo-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-indigo-500">
              Import Events
            </button>
          </div>
        </form>
      </div>

      <%= if @error_message do %>
        <div class="mt-4 p-4 rounded-md bg-red-50 dark:bg-red-900">
          <p class="text-sm text-red-700 dark:text-red-200"><%= @error_message %></p>
        </div>
      <% end %>

      <%= if @success_message do %>
        <div class="mt-4 p-4 rounded-md bg-green-50 dark:bg-green-900">
          <p class="text-sm text-green-700 dark:text-green-200"><%= @success_message %></p>
        </div>
      <% end %>

      <div class="mt-8 text-center">
        <a href="/time" class="text-indigo-600 hover:text-indigo-500 dark:text-indigo-400">
          View Calendar in TimeTracker →
        </a>
      </div>
    </div>
    """
  end
end
