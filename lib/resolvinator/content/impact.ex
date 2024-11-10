defmodule Resolvinator.Content.Impact do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key false
  embedded_schema do
    field :description, :string
    field :area, :string
    field :severity, :string
    field :likelihood, :string
    field :estimated_cost, :decimal
    field :timeframe, :string
    field :notes, :string
  end

  @impact_areas ~w(financial operational reputation regulatory safety technical)

  def changeset(impact, attrs) do
    impact
    |> cast(attrs, [
      :description, :area, :severity, :likelihood,
      :estimated_cost, :timeframe, :notes
    ])
    |> validate_required([:description, :area, :severity])
    |> validate_inclusion(:area, @impact_areas)
  end
end 