defmodule Resolvinator.Requirements.Requirement do
  use Ecto.Schema
  import Ecto.Changeset

  schema "requirements" do
    field :name, :string
    field :priority, :string
    field :status, :string
    field :type, :string
    field :description, :string
    field :validation_criteria, :string
    field :due_date, :date
    field :creator_id, :id
    field :project_id, :id

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(requirement, attrs) do
    requirement
    |> cast(attrs, [:name, :description, :type, :priority, :status, :validation_criteria, :due_date])
    |> validate_required([:name, :description, :type, :priority, :status, :validation_criteria, :due_date])
  end
end
