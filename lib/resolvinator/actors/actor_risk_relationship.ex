defmodule Resolvinator.Actors.ActorRiskRelationship do
  use Ecto.Schema
  import Ecto.Changeset

  @relationship_types ~w(impact responsibility consultation)
  
  schema "actor_risk_relationships" do
    field :relationship_type, :string
    field :description, :string
    field :impact_level, :string
    field :notes, :string

    belongs_to :actor, Resolvinator.Actors.Actor
    belongs_to :risk, Resolvinator.Risks.Risk
    belongs_to :creator, VES.Accounts.User

    timestamps(type: :utc_datetime)
  end

  def changeset(relationship, attrs) do
    relationship
    |> cast(attrs, [:relationship_type, :description, :impact_level, :notes, 
                    :actor_id, :risk_id, :creator_id])
    |> validate_required([:relationship_type, :actor_id, :risk_id])
    |> validate_inclusion(:relationship_type, @relationship_types)
    |> foreign_key_constraint(:actor_id)
    |> foreign_key_constraint(:risk_id)
    |> foreign_key_constraint(:creator_id)
  end 
end
