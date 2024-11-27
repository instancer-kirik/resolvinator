defmodule ResolvinatorWeb.ProjectLive.Index do
  use ResolvinatorWeb, :live_view

  alias Resolvinator.Projects
  alias Resolvinator.Projects.Project
  alias Resolvinator.Acts

  @impl true
  def mount(_params, session, socket) do
    current_user = Accounts.get_user_by_session_token(session["user_token"])
    {:ok, 
      socket
      |> assign(:projects, list_projects())
      |> assign(:current_user_id, current_user.id)
      |> assign(:claiming_project_id, nil)
      |> assign(:token_input, "")}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Project")
    |> assign(:project, Projects.get_project!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Project")
    |> assign(:project, %Project{creator_id: socket.assigns.current_user_id})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Projects")
    |> assign(:project, nil)
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    project = Projects.get_project!(id)
    {:ok, _} = Projects.delete_project(project)

    {:noreply, update(socket, :projects, &List.delete(&1, project))}
  end

  @impl true
  def handle_event("generate-token", %{"id" => id}, socket) do
    project = Projects.get_project!(id)
    {token, updated_project} = Projects.generate_ownership_token(project)

    {:noreply,
     socket
     |> put_flash(:info, "Ownership token: #{token}")
     |> update(:projects, fn projects ->
       Enum.map(projects, fn p -> if p.id == project.id, do: updated_project, else: p end)
     end)}
  end

  @impl true
  def handle_event("show-claim-form", %{"id" => id}, socket) do
    {:noreply, assign(socket, :claiming_project_id, id)}
  end

  @impl true
  def handle_event("hide-claim-form", _, socket) do
    {:noreply, assign(socket, claiming_project_id: nil, token_input: "")}
  end

  @impl true
  def handle_event("update-token-input", %{"value" => value}, socket) do
    {:noreply, assign(socket, :token_input, value)}
  end

  @impl true
  def handle_event("claim-with-token", %{"id" => id}, socket) do
    project = Projects.get_project!(id)
    
    case Projects.claim_project_with_token(project, socket.assigns.token_input, socket.assigns.current_user_id) do
      {:ok, updated_project} ->
        {:noreply,
         socket
         |> put_flash(:info, "Project claimed successfully.")
         |> assign(claiming_project_id: nil, token_input: "")
         |> update(:projects, fn projects ->
           Enum.map(projects, fn p -> if p.id == project.id, do: updated_project, else: p end)
         end)}

      {:error, :invalid_token} ->
        {:noreply,
         socket
         |> put_flash(:error, "Invalid ownership token.")}

      {:error, _} ->
        {:noreply,
         socket
         |> put_flash(:error, "Error claiming project.")}
    end
  end

  defp list_projects do
    Projects.list_projects()
  end
end
