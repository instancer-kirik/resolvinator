defmodule Resolvinator.Risks.Mitigation do
  use Resolvinator.Schema
  import Ecto.Changeset
  alias Resolvinator.Acts.User
  alias Resolvinator.Projects.Project
  alias Resolvinator.Risks.{Risk, MitigationTask}
  alias Resolvinator.Actors.Actor
  alias Resolvinator.Resources.{Resource, Allocation}

  @strategy_values ~w(avoid transfer mitigate accept)
  @status_values ~w(planned in_progress completed cancelled)
  
  schema "mitigations" do
    field :title, :string
    field :description, :string
    field :strategy, :string
    field :status, :string, default: "planned"
    field :effectiveness, :string
    field :cost, :decimal
    field :start_date, :date
    field :target_date, :date
    field :completion_date, :date
    field :notes, :string
    
    belongs_to :risk, Risk
    belongs_to :creator, User
    belongs_to :responsible_actor, Actor
    
    has_many :tasks, MitigationTask
    has_many :resource_allocations, Allocation

    many_to_many :resources, Resource,
      join_through: "mitigation_resources",
      join_keys: [mitigation_id: :id, resource_id: :id]

    timestamps(type: :utc_datetime)
  end

  def changeset(mitigation, attrs) do
    mitigation
    |> cast(attrs, [:title, :description, :strategy, :status, 
                    :effectiveness, :cost, :start_date, :target_date, 
                    :completion_date, :notes, :risk_id, :creator_id, 
                    :responsible_actor_id])
    |> validate_required([:description, :strategy, :status])
    |> validate_inclusion(:strategy, @strategy_values)
    |> validate_inclusion(:status, @status_values)
    |> foreign_key_constraint(:risk_id)
    |> foreign_key_constraint(:creator_id)
    |> foreign_key_constraint(:responsible_actor_id)
  end 
end
