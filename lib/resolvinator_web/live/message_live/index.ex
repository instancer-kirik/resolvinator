defmodule ResolvinatorWeb.MessageLive.Index do
  use ResolvinatorWeb, :live_view

  alias Resolvinator.Messages
  alias Resolvinator.Messages.Message

  @impl true
  def mount(_params, session, socket) do
    current_user_id = session["user_id"]
    
    {:ok,
     socket
     |> assign(:current_user_id, current_user_id)
     |> stream(:messages, Messages.list_messages_for_user(current_user_id))
     |> assign(:search_params, %{
       query: "",
       from_date: nil,
       to_date: nil
     })}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  @impl true
  def handle_info({ResolvinatorWeb.MessageLive.SearchComponent, {:search, params}}, socket) do
    messages = Messages.search_messages(
      Map.merge(params, %{user_id: socket.assigns.current_user_id})
    )
    {:noreply, stream(socket, :messages, messages, reset: true)}
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Message")
    |> assign(:message, %Message{from_user_id: socket.assigns.current_user_id})
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    message = Messages.get_message!(id)
    if authorized_to_edit?(socket.assigns.current_user_id, message) do
      socket
      |> assign(:page_title, "Edit Message")
      |> assign(:message, message)
    else
      socket
      |> put_flash(:error, "You cannot edit this message")
      |> push_navigate(to: ~p"/messages")
    end
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Messages")
    |> assign(:message, nil)
  end

  defp authorized_to_edit?(user_id, message) do
    message.from_user_id == user_id
  end
end
