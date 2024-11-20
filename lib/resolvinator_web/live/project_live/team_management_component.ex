defmodule ResolvinatorWeb.ProjectLive.TeamManagementComponent do
  use ResolvinatorWeb, :live_component

  alias Resolvinator.Projects
  alias Resolvinator.Projects.Team
  alias Chelekom.Components.{Card, Button, Avatar, Table}

  @impl true
  def render(assigns) do
    ~H"""
    <div class="space-y-8">
      <Card.container>
        <Card.header>
          <Card.title>Team Management</Card.title>
          <Card.description>Manage team members and their roles</Card.description>
        </Card.header>

        <Card.content>
          <div class="space-y-6">
            <div class="flex justify-between items-center">
              <div class="flex-1">
                <.form for={@form} phx-submit="add_member" phx-target={@myself} class="flex gap-4">
                  <div class="flex-1">
                    <.input field={@form[:email]} type="email" placeholder="Enter email address" />
                  </div>
                  <div class="flex-1">
                    <.input 
                      field={@form[:role]} 
                      type="select" 
                      options={[
                        {"Owner", "owner"},
                        {"Admin", "admin"},
                        {"Member", "member"},
                        {"Viewer", "viewer"}
                      ]} 
                    />
                  </div>
                  <Button.primary type="submit">Add Member</Button.primary>
                </.form>
              </div>
            </div>

            <Table.container>
              <Table.header>
                <Table.row>
                  <Table.header_cell>Member</Table.header_cell>
                  <Table.header_cell>Role</Table.header_cell>
                  <Table.header_cell>Status</Table.header_cell>
                  <Table.header_cell>Actions</Table.header_cell>
                </Table.row>
              </Table.header>

              <Table.body>
                <%= for member <- @team.members do %>
                  <Table.row>
                    <Table.cell>
                      <div class="flex items-center gap-3">
                        <Avatar.container size="sm">
                          <Avatar.image src={member.avatar_url} />
                          <Avatar.fallback>
                            <%= String.slice(member.name || member.email, 0, 2) %>
                          </Avatar.fallback>
                        </Avatar.container>
                        <div>
                          <div class="font-medium"><%= member.name %></div>
                          <div class="text-sm text-gray-500"><%= member.email %></div>
                        </div>
                      </div>
                    </Table.cell>
                    <Table.cell>
                      <div class="flex items-center">
                        <span class={[
                          "inline-flex items-center rounded-md px-2 py-1 text-xs font-medium",
                          role_color(member.role)
                        ]}>
                          <%= String.capitalize(member.role) %>
                        </span>
                      </div>
                    </Table.cell>
                    <Table.cell>
                      <span class={[
                        "inline-flex items-center rounded-md px-2 py-1 text-xs font-medium",
                        if(member.status == :active, do: "bg-green-50 text-green-700", else: "bg-yellow-50 text-yellow-700")
                      ]}>
                        <%= String.capitalize(to_string(member.status)) %>
                      </span>
                    </Table.cell>
                    <Table.cell>
                      <div class="flex items-center gap-2">
                        <Button.secondary 
                          phx-click="edit_member" 
                          phx-value-id={member.id} 
                          phx-target={@myself}
                          size="sm"
                        >
                          Edit
                        </Button.secondary>
                        <Button.danger 
                          phx-click="remove_member" 
                          phx-value-id={member.id} 
                          phx-target={@myself}
                          size="sm"
                        >
                          Remove
                        </Button.danger>
                      </div>
                    </Table.cell>
                  </Table.row>
                <% end %>
              </Table.body>
            </Table.container>
          </div>
        </Card.content>
      </Card.container>
    </div>
    """
  end

  @impl true
  def update(%{team: team} = assigns, socket) do
    changeset = Team.change_member(%{})

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:form, to_form(changeset))}
  end

  @impl true
  def handle_event("add_member", %{"member" => member_params}, socket) do
    case Projects.add_team_member(socket.assigns.team, member_params) do
      {:ok, team} ->
        send(self(), {__MODULE__, {:member_added, team}})
        {:noreply, socket |> put_flash(:info, "Team member added successfully")}

      {:error, changeset} ->
        {:noreply, assign(socket, :form, to_form(changeset))}
    end
  end

  def handle_event("remove_member", %{"id" => member_id}, socket) do
    case Projects.remove_team_member(socket.assigns.team, member_id) do
      {:ok, team} ->
        send(self(), {__MODULE__, {:member_removed, team}})
        {:noreply, socket |> put_flash(:info, "Team member removed successfully")}

      {:error, _reason} ->
        {:noreply, socket |> put_flash(:error, "Failed to remove team member")}
    end
  end

  def handle_event("edit_member", %{"id" => member_id}, socket) do
    send(self(), {__MODULE__, {:edit_member, member_id}})
    {:noreply, socket}
  end

  defp role_color("owner"), do: "bg-purple-50 text-purple-700"
  defp role_color("admin"), do: "bg-blue-50 text-blue-700"
  defp role_color("member"), do: "bg-green-50 text-green-700"
  defp role_color("viewer"), do: "bg-gray-50 text-gray-700"
end
