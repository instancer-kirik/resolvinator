defmodule ResolvinatorWeb.RiskLive.FormComponent do
  use ResolvinatorWeb, :live_component

  alias Resolvinator.Risks
  alias Resolvinator.Risks.Enums
  alias Phoenix.Naming
  alias Phoenix.LiveView.JS
  alias ResolvinatorWeb.Components.RelationshipModalComponent
  require Logger

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        <%= @title %>
        <:subtitle>Use this form to manage risk records in your database.</:subtitle>
      </.header>

      <.simple_form
        for={@form}
        id="risk-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <.input field={@form[:name]} type="text" label="Name" />
        <.input field={@form[:description]} type="textarea" label="Description" />
        <.input
          field={@form[:probability]}
          type="select"
          label="Probability"
          options={@probability_options}
        />
        <.input
          field={@form[:impact]}
          type="select"
          label="Impact"
          options={@impact_options}
        />
        <.input
          field={@form[:status]}
          type="select"
          label="Status"
          options={@status_options}
        />
        <.input
          field={@form[:mitigation_status]}
          type="select"
          label="Mitigation Status"
          options={@mitigation_options}
        />
        <.input
          field={@form[:detection_date]}
          type="date"
          label="Detection Date"
        />
        <.input
          field={@form[:review_date]}
          type="date"
          label="Review Date"
        />

        <div class="mt-6 flex items-center justify-start gap-4">
          <.button
            type="button"
            phx-click="manage_actors"
            phx-target={@myself}
            disabled={@relationships_disabled}
          >
            Manage Actors
          </.button>

          <.button
            type="button"
            phx-click="manage_mitigations"
            phx-target={@myself}
            disabled={@relationships_disabled}
          >
            Manage Mitigations
          </.button>
        </div>

        <:actions>
          <.button phx-disable-with="Saving...">Save Risk</.button>
        </:actions>
      </.simple_form>

      <%= if @show_actors_modal do %>
        <.live_component
          module={ResolvinatorWeb.Components.RelationshipModalComponent}
          id="actors-modal"
          title="Manage Related Actors"
          subtitle="Add or remove actors associated with this risk"
          item_type="Actors"
          relationship_type="actors"
          available_items={@available_actors}
          related_items={@related_actors}
          on_cancel={JS.push("close_actors_modal", target: @myself)}
        />
      <% end %>

      <%= if @show_mitigations_modal do %>
        <.live_component
          module={ResolvinatorWeb.Components.RelationshipModalComponent}
          id="mitigations-modal"
          title="Manage Mitigations"
          subtitle="Add or remove mitigations for this risk"
          item_type="Mitigations"
          relationship_type="mitigations"
          available_items={@available_mitigations}
          related_items={@related_mitigations}
          on_cancel={JS.push("close_mitigations_modal", target: @myself)}
        />
      <% end %>
    </div>
    """
  end

  @impl true
  def update(%{risk: risk} = assigns, socket) do
    changeset = Risks.change_risk(risk)

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:form, to_form(changeset))
     |> assign(:show_actors_modal, false)
     |> assign(:show_mitigations_modal, false)
     |> assign(:probability_options, probability_options())
     |> assign(:impact_options, impact_options())
     |> assign(:status_options, status_options())
     |> assign(:mitigation_options, mitigation_options())
     |> assign_relationship_data()}
  end

  defp assign_relationship_data(socket) do
    risk = socket.assigns.risk
    
    socket
    |> assign(:available_actors, Risks.list_available_actors(risk))
    |> assign(:related_actors, Risks.list_related_actors(risk))
    |> assign(:available_mitigations, Risks.list_available_mitigations(risk))
    |> assign(:related_mitigations, Risks.list_related_mitigations(risk))
    |> assign(:relationships_disabled, is_nil(risk.id))
  end

  @impl true
  def handle_event("validate", %{"risk" => risk_params}, socket) do
    changeset = Risks.change_risk(socket.assigns.risk, risk_params)
    {:noreply, assign(socket, form: to_form(changeset, action: :validate))}
  end

  def handle_event("save", %{"risk" => risk_params}, socket) do
    save_risk(socket, socket.assigns.action, risk_params)
  end

  defp save_risk(socket, :edit, risk_params) do
    case Risks.update_risk(socket.assigns.risk, risk_params) do
      {:ok, risk} ->
        notify_parent({:saved, risk})

        {:noreply,
         socket
         |> put_flash(:info, "Risk updated successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp save_risk(socket, :new, risk_params) do
    case Risks.create_risk(risk_params) do
      {:ok, risk} ->
        notify_parent({:saved, risk})

        {:noreply,
         socket
         |> put_flash(:info, "Risk created successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})

  @impl true
  def handle_event("manage_actors", _, socket) do
    Logger.info("FormComponent: manage_actors clicked")
    send(self(), {:open_actors_modal, socket.assigns.risk})
    {:noreply, socket}
  end

  @impl true
  def handle_event("manage_mitigations", _, socket) do
    Logger.info("FormComponent: manage_mitigations clicked")
    send(self(), {:open_mitigations_modal, socket.assigns.risk})
    {:noreply, socket}
  end

  @impl true
  def handle_event("close_actors_modal", _, socket) do
    {:noreply, assign(socket, :show_actors_modal, false)}
  end

  @impl true
  def handle_event("close_mitigations_modal", _, socket) do
    {:noreply, assign(socket, :show_mitigations_modal, false)}
  end

  defp probability_options do
    Enums.risk_probabilities()
    |> Enum.map(fn prob -> 
      {prob |> to_string() |> String.capitalize(), prob}
    end)
  end

  defp impact_options do
    Enums.impact_severities()
    |> Enum.map(fn severity -> 
      {severity |> to_string() |> String.capitalize(), severity}
    end)
  end

  defp status_options do
    Enums.risk_statuses()
    |> Enum.map(fn status -> 
      {status |> to_string() |> Naming.humanize(), status}
    end)
  end

  defp mitigation_options do
    Enums.mitigation_statuses()
    |> Enum.map(fn status -> 
      {status |> to_string() |> Naming.humanize(), status}
    end)
  end

  # Alternative: create a helper function for consistent formatting
  defp format_label(atom) do
    atom
    |> to_string()
    |> String.replace("_", " ")
    |> String.capitalize()
  end
end
