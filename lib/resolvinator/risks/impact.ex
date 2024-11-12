defmodule Resolvinator.Risks.Impact do
  use Resolvinator.Risks.ImpactBehavior,
    table_name: "impacts"

  # Extend the schema from ImpactBehavior
  schema "impacts" do
    # Include fields from ImpactBehavior
    field :description, :string
    field :area, :string
    field :severity, :string
    field :likelihood, :string
    field :estimated_cost, :decimal
    field :timeframe, :string
    field :notes, :string

    belongs_to :risk, Resolvinator.Risks.Risk
    belongs_to :creator, Resolvinator.Accounts.User

    many_to_many :affected_actors, Resolvinator.Actors.Actor,
      join_through: "actor_impact_relationships"

    # Add topic relationships
    many_to_many :topics, Resolvinator.Topics.Topic,
      join_through: "content_topic_relationships",
      join_keys: [content_id: :id, topic_id: :id],
      join_where: [content_type: "impact"],
      on_replace: :delete

    timestamps(type: :utc_datetime)
  end

  def changeset(impact, attrs) do
    impact
    |> base_changeset(attrs)
    |> validate_inclusion(:area, @impact_areas)
  end
end
