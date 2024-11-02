defmodule ResolvinatorWeb.UserChannel do
  use ResolvinatorWeb, :channel
  alias ResolvinatorWeb.Presence
  alias Phoenix.PubSub
  require Logger

  @impl true
  def join("user:" <> user_id, _params, socket) do
    if authorized?(socket, user_id) do
      send(self(), :after_join)
      {:ok, socket}
    else
      {:error, %{reason: "unauthorized"}}
    end
  end

  @impl true
  def handle_info(:after_join, socket) do
    {:ok, _} = Presence.track_user(socket)
    push(socket, "presence_state", Presence.list(socket))
    {:noreply, socket}
  end

  @impl true
  def handle_info({:new_message, message}, socket) do
    push(socket, "new_message", message)
    {:noreply, socket}
  end

  @impl true
  def handle_in("new_message", %{"recipient_id" => recipient_id, "content" => content}, socket) do
    with :ok <- validate_rate_limit(socket, "new_message"),
         {:ok, message} <- create_message(socket, recipient_id, content) do
      
      # Broadcast to specific user's channel
      PubSub.broadcast(
        Resolvinator.PubSub,
        "user:#{recipient_id}",
        {:new_message, message}
      )
      
      {:reply, :ok, socket}
    else
      {:error, reason} -> 
        {:reply, {:error, %{reason: reason}}, socket}
    end
  end

  defp authorized?(socket, user_id) do
    String.to_integer(user_id) == socket.assigns.user_id
  end

  @rate_limits %{
    "new_message" => {100, 60_000},   # 100 messages per minute
    "typing" => {30, 10_000},         # 30 typing events per 10 seconds
    "presence" => {10, 60_000}        # 10 presence updates per minute
  }

  defp validate_rate_limit(socket, event_type) do
    {limit, window} = @rate_limits[event_type] || {100, 60_000}
    key = "user_#{socket.assigns.user_id}_#{event_type}"
    
    case Hammer.check_rate(key, window, limit) do
      {:allow, _count} -> :ok
      {:deny, _limit} -> {:error, :rate_limit_exceeded}
    end
  end

  defp create_message(socket, recipient_id, content) do
    # Assuming you have a Messages context
    %{
      from_user_id: socket.assigns.user_id,
      to_user_id: String.to_integer(recipient_id),
      content: content,
      inserted_at: DateTime.utc_now()
    }
    |> then(&{:ok, &1})  # Simulate successful creation for now
  end
end 