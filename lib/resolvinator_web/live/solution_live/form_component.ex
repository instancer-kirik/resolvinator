defmodule ResolvinatorWeb.SolutionLive.FormComponent do
  use ResolvinatorWeb, :live_component

  alias Resolvinator.Content

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        <%= @title %>
        <:subtitle>Use this form to manage solution records in your database.</:subtitle>
      </.header>

      <.simple_form
        for={@form}
        id="solution-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <.input field={@form[:name]} type="text" label="Name" />
        <.input field={@form[:desc]} type="text" label="Desc" />
        <.input field={@form[:upvotes]} type="number" label="Upvotes" />
        <.input field={@form[:downvotes]} type="number" label="Downvotes" />
        <:actions>
          <.button phx-disable-with="Saving...">Save Solution</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def update(%{solution: solution} = assigns, socket) do
    changeset = Content.change_solution(solution)

    {:ok,
     socket
     |> assign(assigns)
     |> assign_form(changeset)}
  end

  @impl true
  def handle_event("validate", %{"solution" => solution_params}, socket) do
    changeset =
      socket.assigns.solution
      |> Content.change_solution(solution_params)
      |> Map.put(:action, :validate)

    {:noreply, assign_form(socket, changeset)}
  end

  def handle_event("save", %{"solution" => solution_params}, socket) do
    save_solution(socket, socket.assigns.action, solution_params)
  end

  defp save_solution(socket, :edit, solution_params) do
    case Content.update_solution(socket.assigns.solution, solution_params) do
      {:ok, solution} ->
        notify_parent({:saved, solution})

        {:noreply,
         socket
         |> put_flash(:info, "Solution updated successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp save_solution(socket, :new, solution_params) do
    case Content.create_solution(solution_params) do
      {:ok, solution} ->
        notify_parent({:saved, solution})

        {:noreply,
         socket
         |> put_flash(:info, "Solution created successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp assign_form(socket, %Ecto.Changeset{} = changeset) do
    assign(socket, :form, to_form(changeset))
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})
end
