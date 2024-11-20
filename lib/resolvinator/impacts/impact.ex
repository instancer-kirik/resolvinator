defmodule Resolvinator.Impacts.Impact do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "impacts" do
    field :description, :string
    field :area, :string
    field :severity, :string
    field :likelihood, :string
    field :timeframe, :string
    field :estimated_cost, :decimal
    field :notes, :string

    # Polymorphic association
    field :impactable_type, :string
    field :impactable_id, :binary_id

    belongs_to :creator, VES.Accounts.User

    many_to_many :affected_actors, Resolvinator.Actors.Actor,
      join_through: "actor_impact_relationships",
      on_replace: :delete

    timestamps(type: :utc_datetime)
  end

  def changeset(impact, attrs) do
    impact
    |> cast(attrs, [
      :description, :area, :severity, :likelihood,
      :timeframe, :estimated_cost, :notes,
      :impactable_type, :impactable_id, :creator_id
    ])
    |> validate_required([:description, :area, :severity])
    |> validate_inclusion(:area, area_options())
    |> validate_inclusion(:severity, severity_options())
    |> validate_inclusion(:likelihood, likelihood_options())
    |> foreign_key_constraint(:creator_id)
  end

  def area_options, do: ~w(business technical security compliance operational financial)
  def severity_options, do: ~w(low medium high critical)
  def likelihood_options, do: ~w(unlikely possible likely certain)
end 