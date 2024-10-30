defmodule ResolvinatorWeb.RiskLive.FormComponent do
  use ResolvinatorWeb, :live_component

  alias Resolvinator.Risks

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
        <.input field={@form[:description]} type="text" label="Description" />
        <.input field={@form[:probability]} type="text" label="Probability" />
        <.input field={@form[:impact]} type="text" label="Impact" />
        <.input field={@form[:priority]} type="text" label="Priority" />
        <.input field={@form[:status]} type="text" label="Status" />
        <.input field={@form[:mitigation_status]} type="text" label="Mitigation status" />
        <.input field={@form[:detection_date]} type="date" label="Detection date" />
        <.input field={@form[:review_date]} type="date" label="Review date" />
        <:actions>
          <.button phx-disable-with="Saving...">Save Risk</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def update(%{risk: risk} = assigns, socket) do
    {:ok,
     socket
     |> assign(assigns)
     |> assign_new(:form, fn ->
       to_form(Risks.change_risk(risk))
     end)}
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
end
