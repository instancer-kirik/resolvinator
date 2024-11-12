defmodule ResolvinatorWeb.RiskLive.Index do
  use ResolvinatorWeb, :live_view
  require Logger

  alias Resolvinator.Risks
  alias Resolvinator.Risks.Risk

  @impl true
  def mount(_params, _session, socket) do
    Logger.debug("Mounting RiskLive.Index")
    {:ok, 
     socket
     |> stream(:risks, Risks.list_risks())
     |> assign(:show_actors_modal, false)
     |> assign(:show_mitigations_modal, false)
     |> assign(:current_risk, nil)
     |> assign(:risk, %Risk{})}
  end

  @impl true
  def handle_info({:open_actors_modal, risk}, socket) do
    Logger.info("LiveView: Opening actors modal for risk #{inspect(risk.id)}")
    {:noreply, 
     socket
     |> assign(:show_actors_modal, true)
     |> assign(:current_risk, risk)}
  end

  @impl true
  def handle_info({:open_mitigations_modal, risk}, socket) do
    Logger.info("LiveView: Opening mitigations modal for risk #{inspect(risk.id)}")
    {:noreply, 
     socket
     |> assign(:show_mitigations_modal, true)
     |> assign(:current_risk, risk)}
  end

  @impl true
  def handle_info({:add_relationship, "actors", actor_id}, socket) do
    risk = socket.assigns.current_risk
    Risks.add_actor_to_risk(risk.id, actor_id)
    {:noreply, socket}
  end

  @impl true
  def handle_info({:remove_relationship, "actors", actor_id}, socket) do
    risk = socket.assigns.current_risk
    Risks.remove_actor_from_risk(risk.id, actor_id)
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

  @impl true
  def handle_params(params, url, socket) do
    Logger.debug("handle_params: #{inspect(params)}, URL: #{url}, live_action: #{inspect(socket.assigns.live_action)}")
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    Logger.debug("Applying edit action")
    socket
    |> assign(:page_title, "Edit Risk")
    |> assign(:risk, Risks.get_risk!(id))
  end

  defp apply_action(socket, :new, _params) do
    Logger.debug("Applying new action")
    socket
    |> assign(:page_title, "New Risk")
    |> assign(:risk, %Risk{})
  end

  defp apply_action(socket, :index, _params) do
    Logger.debug("Applying index action")
    socket
    |> assign(:page_title, "Listing Risks")
    |> assign(:risk, nil)
  end

  @impl true
  def handle_info({ResolvinatorWeb.RiskLive.FormComponent, {:saved, risk}}, socket) do
    {:noreply, stream_insert(socket, :risks, risk)}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    risk = Risks.get_risk!(id)
    {:ok, _} = Risks.delete_risk(risk)

    {:noreply, stream_delete(socket, :risks, risk)}
  end

  @impl true
  def handle_event("close_modal", _, socket) do
    {:noreply, push_patch(socket, to: ~p"/risks")}
  end

  def render(assigns) do
    ~H"""
    <.header>
      Listing Risks
      <:actions>
        <.link patch={~p"/risks/new"}>
          <.button>New Risk</.button>
        </.link>
      </:actions>
    </.header>

    <.table
      id="risks"
      rows={@streams.risks}
    >
      <:col :let={risk} label="Name"><%= risk.name %></:col>
      <:col :let={risk} label="Description"><%= risk.description %></:col>
      <:col :let={risk} label="Status"><%= risk.status %></:col>
      <:action :let={risk}>
        <.link patch={~p"/risks/#{risk}/edit"}>Edit</.link>
      </:action>
    </.table>

    <.modal :if={@live_action in [:new, :edit]} id="risk-modal" show>
      <.live_component
        module={ResolvinatorWeb.RiskLive.FormComponent}
        id={@risk.id || :new}
        title={@page_title}
        action={@live_action}
        risk={@risk}
        patch={~p"/risks"}
      />
    </.modal>

    <%= if @show_actors_modal do %>
      <.modal id="actors-modal" show>
        <.live_component
          module={ResolvinatorWeb.RiskLive.ActorsComponent}
          id="actors-modal"
          risk={@current_risk}
          return_to={~p"/risks"}
        />
      </.modal>
    <% end %>

    <%= if @show_mitigations_modal do %>
      <.modal id="mitigations-modal" show>
        <.live_component
          module={ResolvinatorWeb.RiskLive.MitigationsComponent}
          id="mitigations-modal"
          risk={@current_risk}
          return_to={~p"/risks"}
        />
      </.modal>
    <% end %>
    """
  end
end
