defmodule ResolvinatorWeb.ProjectLive.ProjectTypeComponent do
  use ResolvinatorWeb, :live_component

  alias Resolvinator.Projects.ProjectType
  alias Chelekom.Components.{Card, Button, Badge, Icon}

  @impl true
  def render(assigns) do
    ~H"""
    <div class="space-y-8">
      <Card.container>
        <Card.header>
          <Card.title>Select Project Type</Card.title>
          <Card.description>Choose the type that best matches your project's goals</Card.description>
        </Card.header>

        <Card.content>
          <div class="grid grid-cols-1 gap-6 sm:grid-cols-2 lg:grid-cols-3">
            <%= for {category, types} <- ProjectType.project_type_categories() do %>
              <Card.container>
                <Card.header>
                  <Card.title><%= humanize(category) %></Card.title>
                </Card.header>
                <Card.content>
                  <div class="space-y-4">
                    <%= for type <- types do %>
                      <div class="relative flex items-start">
                        <div class="flex h-6 items-center">
                          <input
                            type="radio"
                            name="project_type"
                            id={"project-type-#{type}"}
                            value={type}
                            checked={@selected_type == type}
                            class="h-4 w-4 border-gray-300 text-primary-600 focus:ring-primary-600"
                            phx-click="select_type"
                            phx-value-type={type}
                            phx-target={@myself}
                          />
                        </div>
                        <div class="ml-3 text-sm leading-6">
                          <label for={"project-type-#{type}"} class="font-medium text-gray-900">
                            <%= humanize(type) %>
                          </label>
                          <p class="text-gray-500">
                            <%= type_description(type) %>
                          </p>
                        </div>
                      </div>
                    <% end %>
                  </div>
                </Card.content>
              </Card.container>
            <% end %>
          </div>
        </Card.content>
      </Card.container>

      <%= if @show_analysis do %>
        <Card.container>
          <Card.header>
            <Card.title>Project Analysis</Card.title>
            <Card.description>Based on your project description, we've analyzed the following:</Card.description>
          </Card.header>

          <Card.content>
            <div class="space-y-6">
              <div>
                <h4 class="text-sm font-medium text-gray-900 mb-3">Requirements</h4>
                <div class="space-y-2">
                  <%= for req <- @requirements do %>
                    <div class="flex items-start gap-2">
                      <Icon.container class="mt-1 h-4 w-4 text-green-500">
                        <Icon.check_circle />
                      </Icon.container>
                      <p class="text-sm text-gray-600"><%= req %></p>
                    </div>
                  <% end %>
                </div>
              </div>

              <div>
                <h4 class="text-sm font-medium text-gray-900 mb-3">Risks</h4>
                <div class="space-y-3">
                  <%= for risk <- @risks do %>
                    <div class="flex items-center justify-between p-3 bg-gray-50 rounded-lg">
                      <span class="text-sm text-gray-900"><%= risk.risk %></span>
                      <div class="flex items-center gap-3">
                        <Badge.status 
                          status={risk_level(risk.probability)} 
                          label={"P: #{format_percentage(risk.probability)}"} 
                        />
                        <Badge.status 
                          status={risk_level(risk.impact)} 
                          label={"I: #{format_percentage(risk.impact)}"} 
                        />
                      </div>
                    </div>
                  <% end %>
                </div>
              </div>
            </div>
          </Card.content>

          <Card.footer>
            <Button.secondary phx-click="reset_analysis" phx-target={@myself}>
              Reset Analysis
            </Button.secondary>
            <Button.primary phx-click="confirm_type" phx-target={@myself}>
              Confirm Type
            </Button.primary>
          </Card.footer>
        </Card.container>
      <% end %>
    </div>
    """
  end

  @impl true
  def update(assigns, socket) do
    {:ok,
     socket
     |> assign(assigns)
     |> assign_new(:selected_type, fn -> nil end)
     |> assign_new(:show_analysis, fn -> false end)
     |> assign_new(:requirements, fn -> [] end)
     |> assign_new(:risks, fn -> [] end)}
  end

  @impl true
  def handle_event("select_type", %{"type" => type}, socket) do
    # Get the implementation module for the selected type
    impl = ProjectType.get_implementation(type)

    # Extract requirements and analyze risks
    {:ok, requirements} = impl.extract_requirements(socket.assigns.project.description)
    {:ok, risks} = impl.analyze_risks(socket.assigns.project.description, %{})

    socket =
      socket
      |> assign(:selected_type, type)
      |> assign(:show_analysis, true)
      |> assign(:requirements, requirements)
      |> assign(:risks, risks)
      |> send_update_to_parent()

    {:noreply, socket}
  end

  def handle_event("reset_analysis", _, socket) do
    {:noreply,
     socket
     |> assign(:selected_type, nil)
     |> assign(:show_analysis, false)
     |> assign(:requirements, [])
     |> assign(:risks, [])}
  end

  def handle_event("confirm_type", _, socket) do
    send(self(), {__MODULE__, {:type_confirmed, %{type: socket.assigns.selected_type}}})
    {:noreply, socket}
  end

  defp send_update_to_parent(socket) do
    send(
      self(),
      {__MODULE__, {:type_selected, %{type: socket.assigns.selected_type}}}
    )
    socket
  end

  defp format_percentage(value) when is_float(value) do
    :io_lib.format("~.1f%", [value * 100])
  end

  defp humanize(string) do
    string
    |> String.replace("_", " ")
    |> String.split(" ")
    |> Enum.map(&String.capitalize/1)
    |> Enum.join(" ")
  end

  defp risk_level(value) when value >= 0.7, do: "high"
  defp risk_level(value) when value >= 0.4, do: "medium"
  defp risk_level(_value), do: "low"

  defp type_description("software"), do: "Software development projects"
  defp type_description("product"), do: "Product development and launch"
  defp type_description("infrastructure"), do: "Infrastructure and system architecture"
  defp type_description("construction"), do: "Construction and physical infrastructure"
  defp type_description("energy"), do: "Energy and utilities projects"
  defp type_description("research"), do: "Research and development initiatives"
  defp type_description("healthcare"), do: "Healthcare and medical projects"
  defp type_description("marketing"), do: "Marketing and promotional campaigns"
  defp type_description("financial"), do: "Financial and investment projects"
  defp type_description("logistics"), do: "Logistics and supply chain"
  defp type_description("analytics"), do: "Data analytics and business intelligence"
  defp type_description("multimedia"), do: "Multimedia and content creation"
  defp type_description("arts"), do: "Arts and creative projects"
  defp type_description("nonprofit"), do: "Nonprofit and social impact"
  defp type_description("education"), do: "Educational and training programs"
  defp type_description(_), do: "General project type"
end
