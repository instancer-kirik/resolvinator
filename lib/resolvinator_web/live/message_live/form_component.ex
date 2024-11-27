defmodule ResolvinatorWeb.MessageLive.FormComponent do
  use ResolvinatorWeb, :live_component
  alias Resolvinator.Messages
  alias Resolvinator.Acts

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        <%= @title %>
        <:subtitle>Send a message to another user</:subtitle>
      </.header>

      <.simple_form
        for={@form}
        id="message-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <%= if @action == :new do %>
          <.live_component
            module={ResolvinatorWeb.Components.EntitySearchComponent}
            id="user-search"
            type={:user}
            selected={@selected_user}
          />
        <% end %>
        
        <.input
          field={@form[:content]}
          type="textarea"
          label="Message"
          rows={4}
        />

        <:actions>
          <.button phx-disable-with="Sending...">
            <%= if @action == :new, do: "Send Message", else: "Update Message" %>
          </.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def update(%{message: message} = assigns, socket) do
    changeset = Messages.change_message(message)
    
    {:ok,
     socket
     |> assign(assigns)
     |> assign(:users, list_users(assigns.current_user_id))
     |> assign_form(changeset)}
  end

  @impl true
  def handle_event("validate", %{"message" => message_params}, socket) do
    changeset =
      socket.assigns.message
      |> Messages.change_message(message_params)
      |> Map.put(:action, :validate)

    {:noreply, assign_form(socket, changeset)}
  end

  def handle_event("save", %{"message" => message_params}, socket) do
    save_message(socket, socket.assigns.action, message_params)
  end

  defp save_message(socket, :edit, message_params) do
    case Messages.update_message(socket.assigns.message, message_params) do
      {:ok, message} ->
        notify_parent({:saved, message})
        {:noreply,
         socket
         |> put_flash(:info, "Message updated successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp save_message(socket, :new, message_params) do
    message_params = Map.put(message_params, "from_user_id", socket.assigns.current_user_id)
    
    case Messages.create_message(message_params) do
      {:ok, message} ->
        notify_parent({:saved, message})
        {:noreply,
         socket
         |> put_flash(:info, "Message sent successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp assign_form(socket, %Ecto.Changeset{} = changeset) do
    assign(socket, :form, to_form(changeset))
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})

  defp list_users(current_user_id) do
    Accounts.list_active_users()
    |> Enum.map(&{&1.email, &1.id})
    |> Enum.reject(fn {_, id} -> id == current_user_id end)
  end
end
