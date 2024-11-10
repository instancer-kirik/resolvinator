defmodule Resolvinator.Risks.Mitigation do
  use Ecto.Schema
  import Ecto.Changeset

  @strategy_values ~w(avoid transfer mitigate accept)
  @status_values ~w(planned in_progress completed cancelled)
  
  schema "mitigations" do
    field :description, :string
    field :strategy, :string
    field :status, :string
    field :effectiveness, :string
    field :cost, :decimal
    field :start_date, :date
    field :target_date, :date
    field :completion_date, :date
    field :notes, :string
    
    belongs_to :risk, Resolvinator.Risks.Risk
    belongs_to :creator, Resolvinator.Accounts.User
    belongs_to :problem, Resolvinator.Content.Problem
    
    many_to_many :responsible_actors, Resolvinator.Actors.Actor,
      join_through: "actor_mitigation_responsibilities"
    
    has_many :tasks, Resolvinator.Risks.MitigationTask
    has_many :resource_allocations, Resolvinator.Resources.Allocation

    timestamps(type: :utc_datetime)
  end

  def changeset(mitigation, attrs) do
    mitigation
    |> cast(attrs, [:description, :strategy, :status, :effectiveness, 
                    :cost, :start_date, :target_date, :completion_date, 
                    :notes, :risk_id, :creator_id, :problem_id])
    |> validate_required([:description, :strategy, :status])
    |> validate_inclusion(:strategy, @strategy_values)
    |> validate_inclusion(:status, @status_values)
    |> foreign_key_constraint(:risk_id)
    |> foreign_key_constraint(:creator_id)
    |> foreign_key_constraint(:problem_id)
  end 
end
