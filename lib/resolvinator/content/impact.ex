defmodule Resolvinator.Content.Impact do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key false  # Important for embedded schemas
  embedded_schema do
    field :severity, :string
    field :likelihood, :string
    field :description, :string
    field :area, :string
    field :timeframe, :string
    field :notes, :string
  end

  def changeset(impact, attrs) do
    impact
    |> cast(attrs, [:severity, :likelihood, :description, :area, :timeframe, :notes])
    |> validate_required([:severity, :likelihood, :description])
  end
end 