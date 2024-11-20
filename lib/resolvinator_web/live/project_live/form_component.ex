defmodule ResolvinatorWeb.ProjectLive.FormComponent do
  use ResolvinatorWeb, :live_component

  alias Resolvinator.Projects
  alias Resolvinator.Accounts
  alias ResolvinatorWeb.ProjectLive.SettingsModalComponent

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
        <div class="space-y-8">
          <div class="space-y-6">
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
          </div>
          
          <div class="pt-6">
            <.button 
              type="button"
              phx-click="open_settings"
              phx-target={@myself}
              class="bg-blue-500 hover:bg-blue-700"
            >
              Configure Project Settings
            </.button>
          </div>
        </div>
        
        <%= if @action == :new do %>
          <.input field={@form[:creator_id]} type="hidden" value={@current_user_id} />
        <% end %>

        <:actions>
          <.button phx-disable-with="Saving...">Save Project</.button>
        </:actions>
      </.simple_form>

      <%= if @show_settings_modal do %>
        <.modal id="settings-modal">
          <.live_component
            module={SettingsModalComponent}
            id="settings-modal"
            project={@project}
            patch={@patch}
          />
        </.modal>
      <% end %>
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
     |> assign(:show_settings_modal, false)
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

  def handle_event("open_settings", _, socket) do
    {:noreply, assign(socket, :show_settings_modal, true)}
  end

  def handle_event("close_settings", _, socket) do
    {:noreply, assign(socket, :show_settings_modal, false)}
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

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})

  defp assign_form(socket, %Ecto.Changeset{} = changeset) do
    assign(socket, :form, to_form(changeset))
  end
end
