defmodule ResolvinatorWeb.EventLive.Builder do
  use ResolvinatorWeb, :live_view

  alias Resolvinator.Events
  alias Resolvinator.AI.FabricAnalysis

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
     |> assign(:validation_errors, %{})}
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
  def handle_info({:ai_suggestions, suggestions}, socket) do
    {:noreply,
     socket
     |> assign(:loading_analysis, false)
     |> assign(:ai_suggestions, suggestions)}
  end

  defp maybe_get_ai_suggestions(socket, :ai_review, params) do
    send_update_after(__MODULE__,
      id: "event-builder",
      action: :analyze_event,
      params: params
    )

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
end
