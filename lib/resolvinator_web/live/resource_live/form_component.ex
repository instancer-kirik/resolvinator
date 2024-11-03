defmodule ResolvinatorWeb.ResourceLive.FormComponent do
  use ResolvinatorWeb, :live_component

  alias Resolvinator.Resources

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        <%= @title %>
        <:subtitle>Use this form to manage resource records in your database.</:subtitle>
      </.header>

      <.simple_form
        for={@form}
        id="resource-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <.input field={@form[:name]} type="text" label="Name" />
        <.input field={@form[:type]} type="text" label="Type" />
        <.input field={@form[:description]} type="text" label="Description" />
        <.input field={@form[:quantity]} type="number" label="Quantity" step="any" />
        <.input field={@form[:unit]} type="text" label="Unit" />
        <.input field={@form[:cost_per_unit]} type="number" label="Cost per unit" step="any" />
        <.input field={@form[:availability_status]} type="text" label="Availability status" />
        <:actions>
          <.button phx-disable-with="Saving...">Save Resource</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def update(%{resource: resource} = assigns, socket) do
    {:ok,
     socket
     |> assign(assigns)
     |> assign_new(:form, fn ->
       to_form(Resources.change_resource(resource))
     end)}
  end

  @impl true
  def handle_event("validate", %{"resource" => resource_params}, socket) do
    changeset = Resources.change_resource(socket.assigns.resource, resource_params)
    {:noreply, assign(socket, form: to_form(changeset, action: :validate))}
  end

  def handle_event("save", %{"resource" => resource_params}, socket) do
    save_resource(socket, socket.assigns.action, resource_params)
  end

  defp save_resource(socket, :edit, resource_params) do
    case Resources.update_resource(socket.assigns.resource, resource_params) do
      {:ok, resource} ->
        notify_parent({:saved, resource})

        {:noreply,
         socket
         |> put_flash(:info, "Resource updated successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp save_resource(socket, :new, resource_params) do
    case Resources.create_resource(resource_params) do
      {:ok, resource} ->
        notify_parent({:saved, resource})

        {:noreply,
         socket
         |> put_flash(:info, "Resource created successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})
end
