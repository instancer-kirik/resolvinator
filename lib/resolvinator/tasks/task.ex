defmodule Resolvinator.Tasks.Task do
  use Resolvinator.Schema
  import Ecto.Changeset
  alias VES.Accounts.User

  schema "tasks" do
    field :title, :string
    field :description, :string
    field :status, :string, default: "pending"
    field :priority, :string, default: "medium"
    field :deadline, :date
    field :completed_at, :naive_datetime
    field :user_id, :id
    field :project_id, :id
    field :parent_task_id, :id

    belongs_to :creator, User
    belongs_to :assignee, User

    timestamps()
  end

  @doc false
  def changeset(task, attrs) do
    task
    |> cast(attrs, [:title, :description, :status, :priority, :deadline, :completed_at, :user_id, :project_id, :parent_task_id])
    |> validate_required([:title, :user_id, :project_id])
    |> validate_inclusion(:status, ["pending", "in_progress", "completed", "blocked"])
    |> validate_inclusion(:priority, ["low", "medium", "high", "urgent"])
    |> maybe_set_completed_at()
  end

  defp maybe_set_completed_at(changeset) do
    case get_change(changeset, :status) do
      "completed" ->
        put_change(changeset, :completed_at, NaiveDateTime.utc_now() |> NaiveDateTime.truncate(:second))
      _ ->
        changeset
    end
  end
end
