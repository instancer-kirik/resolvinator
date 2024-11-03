defmodule Resolvinator.Risks.ImpactBehavior do
  defmacro __using__(opts) do
    quote do
      use Ecto.Schema
      import Ecto.Changeset

      @primary_key {:id, :binary_id, autogenerate: true}
      @foreign_key_type :binary_id
      @impact_areas ~w(financial operational reputation regulatory safety technical)

      schema unquote(opts[:table_name] || raise "table_name is required") do
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

        timestamps(type: :utc_datetime)
      end

      def base_changeset(impact, attrs) do
        impact
        |> cast(attrs, [
          :description, :area, :severity, :likelihood,
          :estimated_cost, :timeframe, :notes,
          :risk_id, :creator_id
        ])
        |> validate_required([:description, :area, :severity, :risk_id])
        |> validate_inclusion(:area, @impact_areas)
        |> foreign_key_constraint(:risk_id)
        |> foreign_key_constraint(:creator_id)
      end
    end
  end
end
