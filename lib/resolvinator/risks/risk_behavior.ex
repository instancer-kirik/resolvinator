defmodule Resolvinator.Risks.RiskBehavior do
  defmacro __using__(_opts) do
    quote do
      use Ecto.Schema
      use Resolvinator.Comments.Commentable
      import Ecto.Changeset

      @priority_values ~w(low medium high critical)
      @status_values ~w(identified analyzing mitigating resolved closed)
      @probability_values ~w(rare unlikely possible likely certain)
      @impact_values ~w(negligible minor moderate major severe)

      # Remove the schema definition since Flint will handle it
      # Instead, define common fields that Flint should include
      @common_fields [
        {:name, :string},
        {:description, :string},
        {:probability, :string},
        {:impact, :string},
        {:priority, :string},
        {:status, :string},
        {:metadata, :map, [default: %{}]}
      ]

      # Common changeset validations
      def base_changeset(risk, attrs) do
        risk
        |> cast(attrs, [:name, :description, :probability, :impact, :priority, :status, :metadata])
        |> validate_required([:name, :description, :probability, :impact, :status])
        |> validate_inclusion(:probability, @probability_values)
        |> validate_inclusion(:impact, @impact_values)
        |> validate_inclusion(:priority, @priority_values)
        |> validate_inclusion(:status, @status_values)
      end
    end
  end
end
