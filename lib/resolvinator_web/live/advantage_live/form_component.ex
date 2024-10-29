defmodule ResolvinatorWeb.AdvantageLive.FormComponent do
  use ResolvinatorWeb, :live_component

  alias Resolvinator.Content

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        <%= @title %>
        <:subtitle>Use this form to manage advantage records in your database.</:subtitle>
      </.header>

      <.simple_form
        for={@form}
        id="advantage-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <.input field={@form[:name]} type="text" label="Name" />
        <.input field={@form[:desc]} type="text" label="Desc" />
        <.input field={@form[:upvotes]} type="number" label="Upvotes" />
        <.input field={@form[:downvotes]} type="number" label="Downvotes" />
        <:actions>
          <.button phx-disable-with="Saving...">Save Advantage</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def update(%{advantage: advantage} = assigns, socket) do
    changeset = Content.change_advantage(advantage)

    {:ok,
     socket
     |> assign(assigns)
     |> assign_form(changeset)}
  end

  @impl true
  def handle_event("validate", %{"advantage" => advantage_params}, socket) do
    changeset =
      socket.assigns.advantage
      |> Content.change_advantage(advantage_params)
      |> Map.put(:action, :validate)

    {:noreply, assign_form(socket, changeset)}
  end

  def handle_event("save", %{"advantage" => advantage_params}, socket) do
    save_advantage(socket, socket.assigns.action, advantage_params)
  end

  defp save_advantage(socket, :edit, advantage_params) do
    case Content.update_advantage(socket.assigns.advantage, advantage_params) do
      {:ok, advantage} ->
        notify_parent({:saved, advantage})

        {:noreply,
         socket
         |> put_flash(:info, "Advantage updated successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp save_advantage(socket, :new, advantage_params) do
    case Content.create_advantage(advantage_params) do
      {:ok, advantage} ->
        notify_parent({:saved, advantage})

        {:noreply,
         socket
         |> put_flash(:info, "Advantage created successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp assign_form(socket, %Ecto.Changeset{} = changeset) do
    assign(socket, :form, to_form(changeset))
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})
end
