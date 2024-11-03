defmodule ResolvinatorWeb.RequirementLive.FormComponent do
  use ResolvinatorWeb, :live_component

  alias Resolvinator.Requirements

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        <%= @title %>
        <:subtitle>Use this form to manage requirement records in your database.</:subtitle>
      </.header>

      <.simple_form
        for={@form}
        id="requirement-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <.input field={@form[:name]} type="text" label="Name" />
        <.input field={@form[:description]} type="text" label="Description" />
        <.input field={@form[:type]} type="text" label="Type" />
        <.input field={@form[:priority]} type="text" label="Priority" />
        <.input field={@form[:status]} type="text" label="Status" />
        <.input field={@form[:validation_criteria]} type="text" label="Validation criteria" />
        <.input field={@form[:due_date]} type="date" label="Due date" />
        <:actions>
          <.button phx-disable-with="Saving...">Save Requirement</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def update(%{requirement: requirement} = assigns, socket) do
    {:ok,
     socket
     |> assign(assigns)
     |> assign_new(:form, fn ->
       to_form(Requirements.change_requirement(requirement))
     end)}
  end

  @impl true
  def handle_event("validate", %{"requirement" => requirement_params}, socket) do
    changeset = Requirements.change_requirement(socket.assigns.requirement, requirement_params)
    {:noreply, assign(socket, form: to_form(changeset, action: :validate))}
  end

  def handle_event("save", %{"requirement" => requirement_params}, socket) do
    save_requirement(socket, socket.assigns.action, requirement_params)
  end

  defp save_requirement(socket, :edit, requirement_params) do
    case Requirements.update_requirement(socket.assigns.requirement, requirement_params) do
      {:ok, requirement} ->
        notify_parent({:saved, requirement})

        {:noreply,
         socket
         |> put_flash(:info, "Requirement updated successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp save_requirement(socket, :new, requirement_params) do
    case Requirements.create_requirement(requirement_params) do
      {:ok, requirement} ->
        notify_parent({:saved, requirement})

        {:noreply,
         socket
         |> put_flash(:info, "Requirement created successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})
end
