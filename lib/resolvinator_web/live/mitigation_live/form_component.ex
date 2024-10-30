defmodule ResolvinatorWeb.MitigationLive.FormComponent do
  use ResolvinatorWeb, :live_component

  alias Resolvinator.Risks

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        <%= @title %>
        <:subtitle>Use this form to manage mitigation records in your database.</:subtitle>
      </.header>

      <.simple_form
        for={@form}
        id="mitigation-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <.input field={@form[:description]} type="text" label="Description" />
        <.input field={@form[:strategy]} type="text" label="Strategy" />
        <.input field={@form[:status]} type="text" label="Status" />
        <.input field={@form[:effectiveness]} type="text" label="Effectiveness" />
        <.input field={@form[:cost]} type="number" label="Cost" step="any" />
        <.input field={@form[:start_date]} type="date" label="Start date" />
        <.input field={@form[:target_date]} type="date" label="Target date" />
        <.input field={@form[:completion_date]} type="date" label="Completion date" />
        <.input field={@form[:notes]} type="text" label="Notes" />
        <:actions>
          <.button phx-disable-with="Saving...">Save Mitigation</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def update(%{mitigation: mitigation} = assigns, socket) do
    {:ok,
     socket
     |> assign(assigns)
     |> assign_new(:form, fn ->
       to_form(Risks.change_mitigation(mitigation))
     end)}
  end

  @impl true
  def handle_event("validate", %{"mitigation" => mitigation_params}, socket) do
    changeset = Risks.change_mitigation(socket.assigns.mitigation, mitigation_params)
    {:noreply, assign(socket, form: to_form(changeset, action: :validate))}
  end

  def handle_event("save", %{"mitigation" => mitigation_params}, socket) do
    save_mitigation(socket, socket.assigns.action, mitigation_params)
  end

  defp save_mitigation(socket, :edit, mitigation_params) do
    case Risks.update_mitigation(socket.assigns.mitigation, mitigation_params) do
      {:ok, mitigation} ->
        notify_parent({:saved, mitigation})

        {:noreply,
         socket
         |> put_flash(:info, "Mitigation updated successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp save_mitigation(socket, :new, mitigation_params) do
    case Risks.create_mitigation(mitigation_params) do
      {:ok, mitigation} ->
        notify_parent({:saved, mitigation})

        {:noreply,
         socket
         |> put_flash(:info, "Mitigation created successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})
end
