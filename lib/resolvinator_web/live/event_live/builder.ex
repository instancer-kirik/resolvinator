defmodule ResolvinatorWeb.EventLive.Builder do
  use ResolvinatorWeb, :live_view

  alias Resolvinator.Events
  alias Resolvinator.AI.FabricAnalysis
  import ResolvinatorWeb.EventBuilderComponents
  import Phoenix.LiveView
  import Phoenix.HTML.Form
  import Phoenix.Naming, only: [humanize: 1]

  @steps [:basic_info, :impact_details, :response_actions, :relationships, :ai_review, :confirmation]

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(:current_step, :basic_info)
     |> assign(:event_params, %{})
     |> assign(:ai_suggestions, nil)
     |> assign(:loading_analysis, false)
     |> assign(:steps, @steps)
     |> assign(:form_data, %{})
     |> assign(:validation_errors, %{})
     |> assign(:show_help, false)}
  end

  @impl true
  def handle_event("next_step", params, socket) do
    current_step = socket.assigns.current_step

    case validate_step(current_step, params) do
      {:ok, validated_params} ->
        updated_params = Map.merge(socket.assigns.event_params, validated_params)
        next_step = get_next_step(current_step)

        socket = socket
        |> assign(:event_params, updated_params)
        |> assign(:current_step, next_step)
        |> maybe_get_ai_suggestions(next_step, updated_params)

        {:noreply, socket}

      {:error, errors} ->
        {:noreply, assign(socket, :validation_errors, errors)}
    end
  end

  @impl true
  def handle_event("previous_step", _params, socket) do
    previous_step = get_previous_step(socket.assigns.current_step)
    {:noreply, assign(socket, :current_step, previous_step)}
  end

  @impl true
  def handle_event("submit", _params, socket) do
    case Events.create_event(socket.assigns.event_params) do
      {:ok, event} ->
        {:noreply,
         socket
         |> put_flash(:info, "Event registered successfully!")
         |> redirect(to: ~p"/events/#{event}")}

      {:error, changeset} ->
        {:noreply,
         socket
         |> put_flash(:error, "Error creating event")
         |> assign(:validation_errors, format_errors(changeset))}
    end
  end

  @impl true
  def handle_info({:analyze_event, params}, socket) do
    case FabricAnalysis.analyze_event(params) do
      {:ok, suggestions} ->
        {:noreply,
         socket
         |> assign(:loading_analysis, false)
         |> assign(:ai_suggestions, suggestions)}

      {:error, _reason} ->
        {:noreply,
         socket
         |> assign(:loading_analysis, false)
         |> put_flash(:error, "Unable to analyze event at this time")}
    end
  end

  defp maybe_get_ai_suggestions(socket, :ai_review, params) do
    Process.send_after(self(), {:analyze_event, params}, 0)
    assign(socket, :loading_analysis, true)
  end
  defp maybe_get_ai_suggestions(socket, _step, _params), do: socket

  defp get_next_step(current_step) do
    current_index = Enum.find_index(@steps, &(&1 == current_step))
    Enum.at(@steps, current_index + 1, List.last(@steps))
  end

  defp get_previous_step(current_step) do
    current_index = Enum.find_index(@steps, &(&1 == current_step))
    Enum.at(@steps, current_index - 1, List.first(@steps))
  end

  defp validate_step(:basic_info, params) do
    case validate_basic_info(params) do
      {:ok, validated} -> {:ok, validated}
      {:error, errors} -> {:error, errors}
    end
  end

  defp validate_step(:impact_details, params) do
    case validate_impact_details(params) do
      {:ok, validated} -> {:ok, validated}
      {:error, errors} -> {:error, errors}
    end
  end

  defp validate_basic_info(params) do
    {:ok, params}
  end

  defp validate_impact_details(params) do
    {:ok, params}
  end

  defp format_errors(changeset) do
    Ecto.Changeset.traverse_errors(changeset, fn {msg, opts} ->
      Enum.reduce(opts, msg, fn {key, value}, acc ->
        String.replace(acc, "%{#{key}}", to_string(value))
      end)
    end)
  end

  def steps(assigns) do
    ~H"""
    <div class="steps">
      <%= for {step, index} <- Enum.with_index(@steps) do %>
        <div class={[
          "step",
          index <= step_index(@current_step) && "active"
        ]}>
          <%= humanize(step) %>
        </div>
      <% end %>
    </div>
    """
  end

  defp step_index(step) do
    Enum.find_index(@steps, &(&1 == step))
  end

  def help_content(assigns) do
    ~H"""
    <div class="help-content">
      <%= case @step do %>
        <% :basic_info -> %>
          <p>Enter the basic details about the event...</p>
        <% :impact_details -> %>
          <p>Describe the impact of the event...</p>
        <% _ -> %>
          <p>Complete the required information...</p>
      <% end %>
    </div>
    """
  end

  def ai_review(assigns) do
    ~H"""
    <div class="ai-review">
      <%= if @loading_analysis do %>
        <div class="loading">Analyzing event...</div>
      <% else %>
        <%= if @ai_suggestions do %>
          <div class="suggestions">
            <!-- Add AI suggestions display -->
          </div>
        <% end %>
      <% end %>
    </div>
    """
  end

  def confirmation_step(assigns) do
    ~H"""
    <div class="confirmation">
      <h3>Review Your Event</h3>
      <!-- Add confirmation step content -->
    </div>
    """
  end

  def relationships_form(assigns) do
    ~H"""
    <div class="relationships-form">
      <!-- Add relationships form content -->
    </div>
    """
  end

  def response_actions_form(assigns) do
    ~H"""
    <div class="response-actions-form">
      <!-- Add response actions form content -->
    </div>
    """
  end
end
