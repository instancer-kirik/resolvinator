defmodule Resolvinator.Risks.MitigationTask do
  use Ecto.Schema
  import Ecto.Changeset

  schema "mitigation_tasks" do
    field :name, :string
    field :description, :string
    field :status, :string
    field :due_date, :date
    field :completion_date, :date
    
    belongs_to :mitigation, Resolvinator.Risks.Mitigation
    belongs_to :creator, Resolvinator.Acts.User
    belongs_to :assignee, Resolvinator.Acts.User

    timestamps(type: :utc_datetime)
  end

  def changeset(task, attrs) do
    task
    |> cast(attrs, [:name, :description, :status, :due_date, 
                    :completion_date, :mitigation_id, :creator_id, :assignee_id])
    |> validate_required([:name, :status, :mitigation_id, :creator_id])
    |> foreign_key_constraint(:mitigation_id)
    |> foreign_key_constraint(:creator_id)
    |> foreign_key_constraint(:assignee_id)
  end 
end
