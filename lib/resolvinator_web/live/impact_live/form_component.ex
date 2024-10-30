defmodule ResolvinatorWeb.ImpactLive.FormComponent do
  use ResolvinatorWeb, :live_component

  alias Resolvinator.Risks

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        <%= @title %>
        <:subtitle>Use this form to manage impact records in your database.</:subtitle>
      </.header>

      <.simple_form
        for={@form}
        id="impact-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <.input field={@form[:description]} type="text" label="Description" />
        <.input field={@form[:area]} type="text" label="Area" />
        <.input field={@form[:severity]} type="text" label="Severity" />
        <.input field={@form[:likelihood]} type="text" label="Likelihood" />
        <.input field={@form[:estimated_cost]} type="number" label="Estimated cost" step="any" />
        <.input field={@form[:timeframe]} type="text" label="Timeframe" />
        <.input field={@form[:notes]} type="text" label="Notes" />
        <:actions>
          <.button phx-disable-with="Saving...">Save Impact</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def update(%{impact: impact} = assigns, socket) do
    {:ok,
     socket
     |> assign(assigns)
     |> assign_new(:form, fn ->
       to_form(Risks.change_impact(impact))
     end)}
  end

  @impl true
  def handle_event("validate", %{"impact" => impact_params}, socket) do
    changeset = Risks.change_impact(socket.assigns.impact, impact_params)
    {:noreply, assign(socket, form: to_form(changeset, action: :validate))}
  end

  def handle_event("save", %{"impact" => impact_params}, socket) do
    save_impact(socket, socket.assigns.action, impact_params)
  end

  defp save_impact(socket, :edit, impact_params) do
    case Risks.update_impact(socket.assigns.impact, impact_params) do
      {:ok, impact} ->
        notify_parent({:saved, impact})

        {:noreply,
         socket
         |> put_flash(:info, "Impact updated successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp save_impact(socket, :new, impact_params) do
    case Risks.create_impact(impact_params) do
      {:ok, impact} ->
        notify_parent({:saved, impact})

        {:noreply,
         socket
         |> put_flash(:info, "Impact created successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})
end
