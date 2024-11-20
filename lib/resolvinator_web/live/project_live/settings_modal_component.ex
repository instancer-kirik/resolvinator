defmodule ResolvinatorWeb.ProjectLive.SettingsModalComponent do
  use ResolvinatorWeb, :live_component

  alias Resolvinator.Projects
  alias Chelekom.Components.{Card, Modal, Button, Tabs}

  @impl true
  def render(assigns) do
    ~H"""
    <div class="space-y-8">
      <Modal.container>
        <Modal.content size="xl">
          <Modal.header>
            <Modal.title>Project Settings</Modal.title>
            <Modal.description>Configure project environment and preferences</Modal.description>
          </Modal.header>

          <div class="mt-6">
            <Tabs.container>
              <Tabs.list>
                <Tabs.item name="metadata">Project Metadata</Tabs.item>
                <Tabs.item name="development">Development</Tabs.item>
                <Tabs.item name="risk">Risk Management</Tabs.item>
                <Tabs.item name="quality">Quality Metrics</Tabs.item>
              </Tabs.list>

              <Tabs.panels>
                <Tabs.panel name="metadata">
                  <Card.container>
                    <Card.content>
                      <div class="grid grid-cols-1 gap-y-6 gap-x-4 sm:grid-cols-6">
                        <div class="sm:col-span-3">
                          <.input field={@form[:settings]["metadata"]["domain"]} type="text" label="Domain" />
                        </div>
                        <div class="sm:col-span-3">
                          <.input field={@form[:settings]["metadata"]["target_audience"]} type="text" label="Target Audience" />
                        </div>
                        <div class="sm:col-span-3">
                          <.input field={@form[:settings]["metadata"]["version"]} type="text" label="Version" />
                        </div>
                        <div class="sm:col-span-3">
                          <.input field={@form[:settings]["metadata"]["license"]} type="text" label="License" />
                        </div>
                        <div class="sm:col-span-6">
                          <.input field={@form[:settings]["metadata"]["repository_url"]} type="url" label="Repository URL" />
                        </div>
                        <div class="sm:col-span-6">
                          <.input field={@form[:settings]["metadata"]["documentation_url"]} type="url" label="Documentation URL" />
                        </div>
                      </div>
                    </Card.content>
                  </Card.container>
                </Tabs.panel>

                <Tabs.panel name="development">
                  <Card.container>
                    <Card.content>
                      <div class="grid grid-cols-1 gap-y-6 gap-x-4 sm:grid-cols-6">
                        <div class="sm:col-span-3">
                          <.input field={@form[:settings]["development"]["build_command"]} type="text" label="Build Command" />
                        </div>
                        <div class="sm:col-span-3">
                          <.input field={@form[:settings]["development"]["run_command"]} type="text" label="Run Command" />
                        </div>
                        <div class="sm:col-span-3">
                          <.input field={@form[:settings]["development"]["test_command"]} type="text" label="Test Command" />
                        </div>
                        <div class="sm:col-span-3">
                          <.input field={@form[:settings]["development"]["lint_command"]} type="text" label="Lint Command" />
                        </div>
                        <div class="sm:col-span-6">
                          <.input field={@form[:settings]["development"]["workspace_path"]} type="text" label="Workspace Path" />
                        </div>
                      </div>
                    </Card.content>
                  </Card.container>
                </Tabs.panel>

                <Tabs.panel name="risk">
                  <Card.container>
                    <Card.content>
                      <div class="grid grid-cols-1 gap-y-6 gap-x-4 sm:grid-cols-6">
                        <div class="sm:col-span-3">
                          <.input 
                            field={@form[:settings]["notification_preferences"]["high_risk_threshold"]} 
                            type="number" 
                            label="High Risk Threshold" 
                          />
                        </div>
                        <div class="sm:col-span-3">
                          <.input 
                            field={@form[:settings]["notification_preferences"]["review_period_days"]} 
                            type="number" 
                            label="Review Period (Days)" 
                          />
                        </div>
                      </div>
                    </Card.content>
                  </Card.container>
                </Tabs.panel>

                <Tabs.panel name="quality">
                  <Card.container>
                    <Card.content>
                      <div class="grid grid-cols-1 gap-y-6 gap-x-4 sm:grid-cols-6">
                        <div class="sm:col-span-2">
                          <.input 
                            field={@form[:settings]["quality_metrics"]["code_coverage_target"]} 
                            type="number" 
                            label="Code Coverage Target (%)" 
                          />
                        </div>
                        <div class="sm:col-span-2">
                          <.input 
                            field={@form[:settings]["quality_metrics"]["test_pass_threshold"]} 
                            type="number" 
                            label="Test Pass Threshold (%)" 
                          />
                        </div>
                        <div class="sm:col-span-2">
                          <.input 
                            field={@form[:settings]["quality_metrics"]["documentation_coverage"]} 
                            type="number" 
                            label="Documentation Coverage (%)" 
                          />
                        </div>
                      </div>
                    </Card.content>
                  </Card.container>
                </Tabs.panel>
              </Tabs.panels>
            </Tabs.container>
          </div>

          <Modal.footer>
            <Button.secondary phx-click="close" phx-target={@myself}>
              Cancel
            </Button.secondary>
            <Button.primary phx-click="save" phx-target={@myself}>
              Save Changes
            </Button.primary>
          </Modal.footer>
        </Modal.content>
      </Modal.container>
    </div>
    """
  end

  @impl true
  def update(%{project: project} = assigns, socket) do
    changeset = Projects.change_project(project)

    {:ok,
     socket
     |> assign(assigns)
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

  def handle_event("save", _, socket) do
    case Projects.update_project(socket.assigns.project, %{settings: socket.assigns.form.params["settings"]}) do
      {:ok, project} ->
        send(self(), {__MODULE__, {:saved, project}})

        {:noreply,
         socket
         |> put_flash(:info, "Project settings updated successfully")}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  def handle_event("close", _, socket) do
    send(self(), {__MODULE__, :close})
    {:noreply, socket}
  end

  defp assign_form(socket, %Ecto.Changeset{} = changeset) do
    assign(socket, :form, to_form(changeset))
  end
end
