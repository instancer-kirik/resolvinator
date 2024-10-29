defmodule ResolvinatorWeb.LessonLive.Index do
  use ResolvinatorWeb, :live_view

  alias Resolvinator.Content
  alias Resolvinator.Content.Lesson

  @impl true
  def mount(_params, _session, socket) do
    {:ok, stream(socket, :lessons, Content.list_lessons())}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Lesson")
    |> assign(:lesson, Content.get_lesson!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Lesson")
    |> assign(:lesson, %Lesson{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Lessons")
    |> assign(:lesson, nil)
  end

  @impl true
  def handle_info({ResolvinatorWeb.LessonLive.FormComponent, {:saved, lesson}}, socket) do
    {:noreply, stream_insert(socket, :lessons, lesson)}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    lesson = Content.get_lesson!(id)
    {:ok, _} = Content.delete_lesson(lesson)

    {:noreply, stream_delete(socket, :lessons, lesson)}
  end
end
