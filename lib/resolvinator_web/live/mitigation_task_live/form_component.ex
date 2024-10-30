defmodule ResolvinatorWeb.MitigationTaskLive.FormComponent do
  use ResolvinatorWeb, :live_component

  alias Resolvinator.Risks

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        <%= @title %>
        <:subtitle>Use this form to manage mitigation_task records in your database.</:subtitle>
      </.header>

      <.simple_form
        for={@form}
        id="mitigation_task-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <.input field={@form[:name]} type="text" label="Name" />
        <.input field={@form[:description]} type="text" label="Description" />
        <.input field={@form[:status]} type="text" label="Status" />
        <.input field={@form[:due_date]} type="date" label="Due date" />
        <.input field={@form[:completion_date]} type="date" label="Completion date" />
        <:actions>
          <.button phx-disable-with="Saving...">Save Mitigation task</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def update(%{mitigation_task: mitigation_task} = assigns, socket) do
    {:ok,
     socket
     |> assign(assigns)
     |> assign_new(:form, fn ->
       to_form(Risks.change_mitigation_task(mitigation_task))
     end)}
  end

  @impl true
  def handle_event("validate", %{"mitigation_task" => mitigation_task_params}, socket) do
    changeset = Risks.change_mitigation_task(socket.assigns.mitigation_task, mitigation_task_params)
    {:noreply, assign(socket, form: to_form(changeset, action: :validate))}
  end

  def handle_event("save", %{"mitigation_task" => mitigation_task_params}, socket) do
    save_mitigation_task(socket, socket.assigns.action, mitigation_task_params)
  end

  defp save_mitigation_task(socket, :edit, mitigation_task_params) do
    case Risks.update_mitigation_task(socket.assigns.mitigation_task, mitigation_task_params) do
      {:ok, mitigation_task} ->
        notify_parent({:saved, mitigation_task})

        {:noreply,
         socket
         |> put_flash(:info, "Mitigation task updated successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp save_mitigation_task(socket, :new, mitigation_task_params) do
    case Risks.create_mitigation_task(mitigation_task_params) do
      {:ok, mitigation_task} ->
        notify_parent({:saved, mitigation_task})

        {:noreply,
         socket
         |> put_flash(:info, "Mitigation task created successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})
end
