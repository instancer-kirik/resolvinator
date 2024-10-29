defmodule ResolvinatorWeb.HandsLive do
  use ResolvinatorWeb, :live_view

  alias Resolvinator.Gestures
  alias Resolvinator.Accounts

  on_mount {ResolvinatorWeb.UserAuth, :mount_current_user}

  @impl true
  def mount(_params, %{"user_token" => user_token}, socket) do
    case Accounts.get_user_by_session_token(user_token) do
      nil ->
        {:error, "User not found"}

      user ->
        gestures = Gestures.list_gestures(user.id)
        socket =
          socket
          |> assign(:current_user, user)
          |> assign(:gestures, gestures)
          |> assign(:fingers_pressed, [0, 0, 0, 0, 0])
        
        {:ok, socket}
    end
  end
end
