defmodule Resolvinator.Requirements.Requirement do
  use Ecto.Schema
  import Ecto.Changeset

  @type_values ~w(budget staff equipment material time facility service)
  @status_values ~w(requested approved allocated in_use completed)

  schema "requirements" do
    field :name, :string
    field :type, :string
    field :quantity, :decimal
    field :unit, :string        # hours, pieces, USD, etc.
    field :priority, :string
    field :status, :string
    field :start_date, :date
    field :end_date, :date
    field :notes, :text
    field :estimated_cost, :decimal

    # Core relationships
    belongs_to :risk, Resolvinator.Risks.Risk
    belongs_to :mitigation, Resolvinator.Risks.Mitigation
    belongs_to :creator, Resolvinator.Accounts.User
    belongs_to :project, Resolvinator.Projects.Project

    # Who's responsible for providing/managing this requirement
    belongs_to :responsible_actor, Resolvinator.Actors.Actor

    timestamps(type: :utc_datetime)
  end

  def changeset(requirement, attrs) do
    requirement
    |> cast(attrs, [:name, :type, :quantity, :unit, :priority, :status,
                    :start_date, :end_date, :notes, :estimated_cost,
                    :risk_id, :mitigation_id, :creator_id, :project_id,
                    :responsible_actor_id])
    |> validate_required([:name, :type, :quantity, :status, :creator_id, :project_id])
    |> validate_inclusion(:type, @type_values)
    |> validate_inclusion(:status, @status_values)
    |> foreign_key_constraint(:risk_id)
    |> foreign_key_constraint(:mitigation_id)
    |> foreign_key_constraint(:creator_id)
    |> foreign_key_constraint(:project_id)
    |> foreign_key_constraint(:responsible_actor_id)
    |> check_constraint(:requirement_owner, 
        name: :must_belong_to_risk_or_mitigation,
        message: "must belong to either a risk or a mitigation")
  end 
end