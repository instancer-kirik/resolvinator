defmodule ResolvinatorWeb.Presence do
  use Phoenix.Presence,
    otp_app: :resolvinator,
    pubsub_server: Resolvinator.PubSub

  def track_user(socket) do
    track(
      socket,
      socket.assigns.user_id,
      %{
        online_at: DateTime.utc_now(),
        status: "online",
        client_version: socket.assigns.client_version
      }
    )
  end

  def update_user_status(socket, status) when status in ["online", "away", "busy"] do
    update(socket, socket.assigns.user_id, fn meta -> 
      Map.put(meta, :status, status)
    end)
  end
end 