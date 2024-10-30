defmodule ResolvinatorWeb.ActorLive.FormComponent do
  use ResolvinatorWeb, :live_component

  alias Resolvinator.Actors

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        <%= @title %>
        <:subtitle>Use this form to manage actor records in your database.</:subtitle>
      </.header>

      <.simple_form
        for={@form}
        id="actor-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <.input field={@form[:name]} type="text" label="Name" />
        <.input field={@form[:type]} type="text" label="Type" />
        <.input field={@form[:description]} type="text" label="Description" />
        <.input field={@form[:role]} type="text" label="Role" />
        <.input field={@form[:influence_level]} type="text" label="Influence level" />
        <.input field={@form[:status]} type="text" label="Status" />
        <:actions>
          <.button phx-disable-with="Saving...">Save Actor</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def update(%{actor: actor} = assigns, socket) do
    {:ok,
     socket
     |> assign(assigns)
     |> assign_new(:form, fn ->
       to_form(Actors.change_actor(actor))
     end)}
  end

  @impl true
  def handle_event("validate", %{"actor" => actor_params}, socket) do
    changeset = Actors.change_actor(socket.assigns.actor, actor_params)
    {:noreply, assign(socket, form: to_form(changeset, action: :validate))}
  end

  def handle_event("save", %{"actor" => actor_params}, socket) do
    save_actor(socket, socket.assigns.action, actor_params)
  end

  defp save_actor(socket, :edit, actor_params) do
    case Actors.update_actor(socket.assigns.actor, actor_params) do
      {:ok, actor} ->
        notify_parent({:saved, actor})

        {:noreply,
         socket
         |> put_flash(:info, "Actor updated successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp save_actor(socket, :new, actor_params) do
    case Actors.create_actor(actor_params) do
      {:ok, actor} ->
        notify_parent({:saved, actor})

        {:noreply,
         socket
         |> put_flash(:info, "Actor created successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})
end
