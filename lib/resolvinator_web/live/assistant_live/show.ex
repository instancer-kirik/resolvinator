defmodule ResolvinatorWeb.AssistantLive.Show do
  use ResolvinatorWeb, :live_view
  alias Resolvinator.AI.FabricAnalysis
  alias Phoenix.LiveView.JS

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(:messages, [])
     |> assign(:loading, false)}
  end

  @impl true
  def handle_event("send_message", %{"message" => message}, socket) do
    messages = socket.assigns.messages
    user_message = %{role: :user, content: message}
    
    {:noreply,
     socket
     |> assign(:loading, true)
     |> assign(:messages, messages ++ [user_message])
     |> start_ai_response(message)}
  end

  @impl true
  def handle_info({:ai_response, response}, socket) do
    messages = socket.assigns.messages
    ai_message = %{role: :assistant, content: response}
    
    {:noreply,
     socket
     |> assign(:loading, false)
     |> assign(:messages, messages ++ [ai_message])}
  end

  defp start_ai_response(socket, message) do
    pid = self()
    
    Task.start(fn ->
      response = FabricAnalysis.analyze_query(message)
      send(pid, {:ai_response, response})
    end)
    
    socket
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="max-w-4xl mx-auto p-4">
      <h1 class="text-2xl font-bold mb-4">AI Assistant</h1>
      
      <div class="bg-white rounded-lg shadow-lg p-4 mb-4 h-[60vh] overflow-y-auto">
        <div id="messages" phx-update="append">
          <%= for {message, i} <- Enum.with_index(@messages) do %>
            <div id={"message-#{i}"} class={[
              "mb-4 p-3 rounded-lg",
              message.role == :user && "bg-blue-100 ml-8",
              message.role == :assistant && "bg-gray-100 mr-8"
            ]}>
              <p class="text-sm font-semibold mb-1">
                <%= if message.role == :user, do: "You", else: "Assistant" %>
              </p>
              <p class="text-gray-700"><%= message.content %></p>
            </div>
          <% end %>
        </div>
        
        <%= if @loading do %>
          <div class="flex items-center space-x-2 text-gray-500">
            <span>Thinking</span>
            <div class="animate-bounce">.</div>
            <div class="animate-bounce animation-delay-200">.</div>
            <div class="animate-bounce animation-delay-400">.</div>
          </div>
        <% end %>
      </div>
      
      <form phx-submit="send_message" class="flex space-x-2">
        <input
          type="text"
          name="message"
          class="flex-1 rounded-lg border-gray-300 shadow-sm focus:border-blue-500 focus:ring-blue-500"
          placeholder="Ask about your data..."
          autocomplete="off"
        />
        <button type="submit" class="px-4 py-2 bg-blue-500 text-white rounded-lg hover:bg-blue-600">
          Send
        </button>
      </form>
    </div>
    """
  end
end 