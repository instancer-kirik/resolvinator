defmodule ResolvinatorWeb.ProjectLive.FormComponent do
  use ResolvinatorWeb, :live_component

  alias Resolvinator.Projects
  alias Resolvinator.Accounts

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        <%= @title %>
        <:subtitle>Use this form to manage project records in your database.</:subtitle>
      </.header>

      <.simple_form
        for={@form}
        id="project-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <.input field={@form[:name]} type="text" label="Name" />
        <.input field={@form[:description]} type="text" label="Description" />
        <.input field={@form[:status]} type="select" label="Status" 
                options={[{"Planning", "planning"}, {"Active", "active"}, 
                         {"On Hold", "on_hold"}, {"Completed", "completed"}, 
                         {"Archived", "archived"}]} />
        <.input field={@form[:risk_appetite]} type="select" label="Risk appetite" 
                options={[{"Averse", "averse"}, {"Minimal", "minimal"}, 
                         {"Cautious", "cautious"}, {"Flexible", "flexible"}, 
                         {"Aggressive", "aggressive"}]} />
        <.input field={@form[:start_date]} type="date" label="Start date" />
        <.input field={@form[:target_date]} type="date" label="Target date" />
        <.input field={@form[:completion_date]} type="date" label="Completion date" />
        
        <%= if @action == :new do %>
          <.input field={@form[:creator_id]} type="hidden" value={@current_user_id} />
        <% end %>

        <:actions>
          <.button phx-disable-with="Saving...">Save Project</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def update(%{project: project} = assigns, socket) do
    changeset = Projects.change_project(project)

    {:ok,
     socket
     |> assign(assigns)
     |> assign_new(:current_user_id, fn -> assigns[:current_user_id] end)
     |> assign_form(changeset)}
  end

  @impl true
  def handle_event("validate", %{"project" => project_params}, socket) do
    changeset =
      socket.assigns.project
      |> Projects.change_project(project_params)
      |> Map.put(:action, :validate)

    {:noreply, assign_form(socket, changeset)}
  end

  def handle_event("save", %{"project" => project_params}, socket) do
    save_project(socket, socket.assigns.action, project_params)
  end

  defp save_project(socket, :edit, project_params) do
    case Projects.update_project(socket.assigns.project, project_params) do
      {:ok, project} ->
        notify_parent({:saved, project})

        {:noreply,
         socket
         |> put_flash(:info, "Project updated successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp save_project(socket, :new, project_params) do
    case Projects.create_project(project_params) do
      {:ok, project} ->
        notify_parent({:saved, project})

        {:noreply,
         socket
         |> put_flash(:info, "Project created successfully")
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
