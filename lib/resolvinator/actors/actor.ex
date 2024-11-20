defmodule Resolvinator.Actors.Actor do
  use Flint.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  @timestamps_opts [type: :utc_datetime]

  @type_values ~w(stakeholder organization department team individual regulator supplier customer)
  @role_values ~w(affected responsible accountable consulted informed)
  @influence_values ~w(high medium low)

  schema "actors" do
    field :name, :string
    field :type, :string
    field :description, :string
    field :role, :string
    field :influence_level, :string
    field :contact_info, :map
    field :status, :string, default: "active"

    belongs_to :creator, VES.Accounts.User
    belongs_to :project, Resolvinator.Projects.Project

    # Hierarchical relationship
    belongs_to :parent_actor, __MODULE__
    has_many :sub_actors, __MODULE__, foreign_key: :parent_actor_id

    # Risk relationships
    many_to_many :affected_by_risks, Resolvinator.Risks.Risk,
      join_through: "actor_risk_associations",
      join_keys: [actor_id: :id, risk_id: :id],
      on_replace: :delete

    many_to_many :responsible_for_risks, Resolvinator.Risks.Risk,
      join_through: "actor_risk_responsibilities",
      join_keys: [actor_id: :id, risk_id: :id],
      on_replace: :delete

    many_to_many :consulted_for_risks, Resolvinator.Risks.Risk,
      join_through: "actor_risk_consultations",
      join_keys: [actor_id: :id, risk_id: :id],
      on_replace: :delete

    timestamps(type: :utc_datetime)
  end

  def changeset(actor, attrs) do
    actor
    |> cast(attrs, [:name, :type, :description, :role, :influence_level,
                    :contact_info, :status, :creator_id, :project_id, :parent_actor_id])
    |> validate_required([:name, :type, :role])
    |> validate_inclusion(:type, @type_values)
    |> validate_inclusion(:role, @role_values)
    |> validate_inclusion(:influence_level, @influence_values)
    |> foreign_key_constraint(:creator_id)
    |> foreign_key_constraint(:project_id)
    |> foreign_key_constraint(:parent_actor_id)
  end
end
