defmodule ResolvinatorWeb.ProjectLive.RiskAnalysisComponent do
  use ResolvinatorWeb, :live_component

  alias Resolvinator.Projects
  alias Resolvinator.Projects.Risk
  alias Chelekom.Components.{Card, Button, Table, Badge}

  @impl true
  def render(assigns) do
    ~H"""
    <div class="space-y-8">
      <Card.container>
        <Card.header>
          <Card.title>Risk Analysis</Card.title>
          <Card.description>Monitor and manage project risks</Card.description>
        </Card.header>

        <Card.content>
          <div class="space-y-6">
            <div class="flex justify-between items-center">
              <div class="flex-1">
                <.form for={@form} phx-submit="add_risk" phx-target={@myself} class="flex gap-4">
                  <div class="flex-1">
                    <.input field={@form[:description]} type="text" placeholder="Risk description" />
                  </div>
                  <div class="w-32">
                    <.input 
                      field={@form[:probability]} 
                      type="select" 
                      options={[
                        {"Low", "low"},
                        {"Medium", "medium"},
                        {"High", "high"}
                      ]} 
                    />
                  </div>
                  <div class="w-32">
                    <.input 
                      field={@form[:impact]} 
                      type="select" 
                      options={[
                        {"Low", "low"},
                        {"Medium", "medium"},
                        {"High", "high"}
                      ]} 
                    />
                  </div>
                  <Button.primary type="submit">Add Risk</Button.primary>
                </.form>
              </div>
            </div>

            <div class="grid grid-cols-2 gap-8">
              <div>
                <h3 class="text-lg font-medium mb-4">Risk Matrix</h3>
                <div class="grid grid-cols-4 gap-1 border rounded-lg p-4">
                  <div class="col-span-1"></div>
                  <%= for impact <- ["low", "medium", "high"] do %>
                    <div class="text-center text-sm font-medium">
                      <%= String.capitalize(impact) %> Impact
                    </div>
                  <% end %>

                  <%= for probability <- ["high", "medium", "low"] do %>
                    <div class="text-right pr-2 text-sm font-medium">
                      <%= String.capitalize(probability) %>
                    </div>
                    <%= for impact <- ["low", "medium", "high"] do %>
                      <div class={[
                        "p-2 text-center rounded-md",
                        risk_matrix_color(probability, impact)
                      ]}>
                        <%= length(filter_risks(@risks, probability, impact)) %>
                      </div>
                    <% end %>
                  <% end %>
                </div>
              </div>

              <div>
                <h3 class="text-lg font-medium mb-4">Risk Trends</h3>
                <div class="border rounded-lg p-4">
                  <div class="grid grid-cols-3 gap-4">
                    <div class="text-center">
                      <div class="text-2xl font-bold text-red-600">
                        <%= length(filter_risks_by_severity(@risks, "high")) %>
                      </div>
                      <div class="text-sm text-gray-500">High Severity</div>
                    </div>
                    <div class="text-center">
                      <div class="text-2xl font-bold text-yellow-600">
                        <%= length(filter_risks_by_severity(@risks, "medium")) %>
                      </div>
                      <div class="text-sm text-gray-500">Medium Severity</div>
                    </div>
                    <div class="text-center">
                      <div class="text-2xl font-bold text-green-600">
                        <%= length(filter_risks_by_severity(@risks, "low")) %>
                      </div>
                      <div class="text-sm text-gray-500">Low Severity</div>
                    </div>
                  </div>
                </div>
              </div>
            </div>

            <Table.container>
              <Table.header>
                <Table.row>
                  <Table.header_cell>Description</Table.header_cell>
                  <Table.header_cell>Probability</Table.header_cell>
                  <Table.header_cell>Impact</Table.header_cell>
                  <Table.header_cell>Severity</Table.header_cell>
                  <Table.header_cell>Actions</Table.header_cell>
                </Table.row>
              </Table.header>

              <Table.body>
                <%= for risk <- @risks do %>
                  <Table.row>
                    <Table.cell><%= risk.description %></Table.cell>
                    <Table.cell>
                      <Badge.status status={risk.probability} />
                    </Table.cell>
                    <Table.cell>
                      <Badge.status status={risk.impact} />
                    </Table.cell>
                    <Table.cell>
                      <Badge.status status={calculate_severity(risk)} />
                    </Table.cell>
                    <Table.cell>
                      <div class="flex items-center gap-2">
                        <Button.secondary 
                          phx-click="edit_risk" 
                          phx-value-id={risk.id} 
                          phx-target={@myself}
                          size="sm"
                        >
                          Edit
                        </Button.secondary>
                        <Button.danger 
                          phx-click="remove_risk" 
                          phx-value-id={risk.id} 
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
  def update(%{project: project} = assigns, socket) do
    changeset = Risk.changeset(%Risk{}, %{})

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:risks, Projects.list_project_risks(project))
     |> assign(:form, to_form(changeset))}
  end

  @impl true
  def handle_event("add_risk", %{"risk" => risk_params}, socket) do
    case Projects.add_project_risk(socket.assigns.project, risk_params) do
      {:ok, _risk} ->
        {:noreply,
         socket
         |> assign(:risks, Projects.list_project_risks(socket.assigns.project))
         |> assign(:form, to_form(Risk.changeset(%Risk{}, %{})))
         |> put_flash(:info, "Risk added successfully")}

      {:error, changeset} ->
        {:noreply, assign(socket, :form, to_form(changeset))}
    end
  end

  def handle_event("remove_risk", %{"id" => risk_id}, socket) do
    case Projects.remove_project_risk(socket.assigns.project, risk_id) do
      {:ok, _} ->
        {:noreply,
         socket
         |> assign(:risks, Projects.list_project_risks(socket.assigns.project))
         |> put_flash(:info, "Risk removed successfully")}

      {:error, _} ->
        {:noreply, socket |> put_flash(:error, "Failed to remove risk")}
    end
  end

  def handle_event("edit_risk", %{"id" => risk_id}, socket) do
    send(self(), {__MODULE__, {:edit_risk, risk_id}})
    {:noreply, socket}
  end

  defp filter_risks(risks, probability, impact) do
    Enum.filter(risks, &(&1.probability == probability && &1.impact == impact))
  end

  defp filter_risks_by_severity(risks, severity) do
    Enum.filter(risks, &(calculate_severity(&1) == severity))
  end

  defp calculate_severity(%{probability: prob, impact: imp}) do
    case {prob, imp} do
      {"high", "high"} -> "high"
      {"high", "medium"} -> "high"
      {"medium", "high"} -> "high"
      {"low", "low"} -> "low"
      {"low", "medium"} -> "low"
      {"medium", "low"} -> "low"
      _ -> "medium"
    end
  end

  defp risk_matrix_color("high", "high"), do: "bg-red-100"
  defp risk_matrix_color("high", "medium"), do: "bg-red-50"
  defp risk_matrix_color("high", "low"), do: "bg-yellow-50"
  defp risk_matrix_color("medium", "high"), do: "bg-red-50"
  defp risk_matrix_color("medium", "medium"), do: "bg-yellow-100"
  defp risk_matrix_color("medium", "low"), do: "bg-yellow-50"
  defp risk_matrix_color("low", "high"), do: "bg-yellow-50"
  defp risk_matrix_color("low", "medium"), do: "bg-green-50"
  defp risk_matrix_color("low", "low"), do: "bg-green-100"
end
