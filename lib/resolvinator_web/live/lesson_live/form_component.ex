defmodule ResolvinatorWeb.LessonLive.FormComponent do
  use ResolvinatorWeb, :live_component

  alias Resolvinator.Content

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        <%= @title %>
        <:subtitle>Use this form to manage lesson records in your database.</:subtitle>
      </.header>

      <.simple_form
        for={@form}
        id="lesson-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <.input field={@form[:name]} type="text" label="Name" />
        <.input field={@form[:desc]} type="text" label="Desc" />

        <:actions>
          <.button phx-disable-with="Saving...">Save Lesson</.button>
        </:actions>
      </.simple_form>

    </div>
    """
  end
  #<.input field={@form[:upvotes]} type="number" label="Upvotes" />
  # <.input field={@form[:downvotes]} type="number" label="Downvotes" />


  @impl true
  def update(%{lesson: lesson} = assigns, socket) do
    changeset = Content.change_lesson(lesson)
    # problems = Content.list_problems() |> Enum.map(&{&1.name, &1.id})
    # solutions = Content.list_solutions() |> Enum.map(&{&1.name, &1.id})
    # selected_problem_ids = Enum.map(lesson.problems, & &1.id)
    # selected_solution_ids = Enum.map(lesson.solutions, & &1.id)

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:form, to_form(changeset))}
    #  |> assign(changeset)}
    #  |> assign(:problems, problems)
    #  |> assign(:solutions, solutions)
    #  |> assign(:selected_problem_ids, [])
    #  |> assign(:selected_solution_ids, [])}
  end

  @impl true
  def handle_event("validate", %{"lesson" => lesson_params}, socket) do
    changeset =
      socket.assigns.lesson
      |> Content.change_lesson(lesson_params)
      |> Map.put(:action, :validate)

    {:noreply, assign_form(socket, changeset)}
  end

  def handle_event("save", %{"lesson" => lesson_params}, socket) do
    save_lesson(socket, socket.assigns.action, lesson_params)
  end

  defp save_lesson(socket, :edit, lesson_params) do
    case Content.update_lesson(socket.assigns.lesson, lesson_params) do
      {:ok, lesson} ->
        notify_parent({:saved, lesson})

        {:noreply,
         socket
         |> put_flash(:info, "Lesson updated successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp save_lesson(socket, :new, lesson_params) do
    case Content.create_lesson(lesson_params) do
      {:ok, lesson} ->
        notify_parent({:saved, lesson})

        {:noreply,
         socket
         |> put_flash(:info, "Lesson created successfully")
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
