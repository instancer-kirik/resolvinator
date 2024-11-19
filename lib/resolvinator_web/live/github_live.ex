defmodule ResolvinatorWeb.GitHubLive do
  use ResolvinatorWeb, :live_view

  alias Resolvinator.GitHub

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, 
      repo_url: "",
      branch: "main",
      custom_path: "",
      error_message: nil,
      success_message: nil,
      show_path_selector: false
    )}
  end

  @impl true
  def handle_event("clone", %{"repo" => %{"url" => url, "branch" => branch, "path" => path}}, socket) do
    opts = [
      branch: branch,
      path: if(path != "", do: path, else: nil)
    ]

    case GitHub.clone_repository(url, opts) do
      {:ok, repo_path} ->
        GitHub.open_in_deepscape(repo_path)
        {:noreply, 
         socket
         |> assign(:success_message, "Repository cloned and opened in Deepscape!")
         |> assign(:error_message, nil)}

      {:error, reason} ->
        {:noreply, 
         socket
         |> assign(:error_message, "Failed to clone repository: #{inspect(reason)}")
         |> assign(:success_message, nil)}
    end
  end

  @impl true
  def handle_event("toggle_path_selector", _, socket) do
    {:noreply, assign(socket, :show_path_selector, !socket.assigns.show_path_selector)}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="max-w-2xl mx-auto p-6">
      <h1 class="text-3xl font-bold mb-8 text-gray-900 dark:text-white">GitHub Repository Manager</h1>
      
      <.form for={%{}} phx-submit="clone" class="space-y-6">
        <div>
          <label class="block text-sm font-medium text-gray-700 dark:text-gray-300">
            Repository URL
          </label>
          <input type="text" name="repo[url]" class="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-indigo-500 focus:ring-indigo-500 dark:bg-gray-800 dark:border-gray-600"
                 placeholder="https://github.com/username/repo.git" required>
        </div>

        <div>
          <label class="block text-sm font-medium text-gray-700 dark:text-gray-300">
            Branch
          </label>
          <input type="text" name="repo[branch]" value="main" class="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-indigo-500 focus:ring-indigo-500 dark:bg-gray-800 dark:border-gray-600">
        </div>

        <div>
          <div class="flex items-center justify-between">
            <label class="block text-sm font-medium text-gray-700 dark:text-gray-300">
              Custom Path (optional)
            </label>
            <button type="button" phx-click="toggle_path_selector"
                    class="text-sm text-indigo-600 hover:text-indigo-500 dark:text-indigo-400">
              <%= if @show_path_selector, do: "Hide", else: "Show" %>
            </button>
          </div>
          
          <%= if @show_path_selector do %>
            <input type="text" name="repo[path]" class="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-indigo-500 focus:ring-indigo-500 dark:bg-gray-800 dark:border-gray-600"
                   placeholder="/path/to/your/workspace">
            <p class="mt-1 text-sm text-gray-500 dark:text-gray-400">
              Leave empty to use default workspace path
            </p>
          <% else %>
            <input type="hidden" name="repo[path]" value="">
          <% end %>
        </div>

        <button type="submit" class="w-full flex justify-center py-2 px-4 border border-transparent rounded-md shadow-sm text-sm font-medium text-white bg-indigo-600 hover:bg-indigo-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-indigo-500">
          Clone and Open in Deepscape
        </button>
      </.form>

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
    </div>
    """
  end
end
