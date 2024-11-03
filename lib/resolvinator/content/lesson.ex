defmodule Resolvinator.Content.Lesson do
  use Flint.Schema
  alias Flint.Schema
  import Ecto.Changeset
  import Ecto.Query

  use Resolvinator.Content.ContentBehavior,
    type_name: :lesson,
    table_name: "lessons",
    relationship_table: "lesson_relationships",
    description_table: "lesson_descriptions",
    relationship_keys: [lesson_id: :id, related_lesson_id: :id],
    description_keys: [lesson_id: :id, description_id: :id]

  def changeset(lesson, attrs) do
    lesson
    |> base_changeset(attrs)
  end
end

defmodule Resolvinator.Content.LessonDescription do
  use Resolvinator.Content.ContentDescription,
    table_name: "lesson_descriptions",
    content_type: :lesson,
    content_module: Resolvinator.Content.Lesson,
    foreign_key: :lesson_id
end
