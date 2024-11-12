defmodule Resolvinator.Risks.ImpactBehavior do
  defmacro __using__(_opts) do
    quote do
      use Ecto.Schema
      import Ecto.Changeset
      alias Resolvinator.Risks.Enums

      @primary_key {:id, :binary_id, autogenerate: true}
      @foreign_key_type :binary_id

      def base_changeset(impact, attrs) do
        impact
        |> cast(attrs, [
          :description, :area, :severity, :likelihood,
          :estimated_cost, :timeframe, :notes,
          :risk_id, :creator_id
        ])
        |> validate_required([:description, :area, :severity, :risk_id])
        |> validate_inclusion(:area, Enums.impact_areas())
        |> validate_inclusion(:severity, Enums.impact_severities())
        |> validate_inclusion(:likelihood, Enums.impact_likelihoods())
        |> foreign_key_constraint(:risk_id)
        |> foreign_key_constraint(:creator_id)
      end
    end
  end
end
