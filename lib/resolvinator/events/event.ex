defmodule Resolvinator.Events.Event do
  use Ecto.Schema
  import Ecto.Changeset
  use Resolvinator.Comments.Commentable

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  @event_types ~w(risk_occurrence mitigation_outcome impact_manifestation control_failure near_miss)
  @severity_levels ~w(negligible minor moderate major severe)

  schema "events" do
    field :title, :string
    field :description, :string
    field :event_type, :string
    field :severity, :string
    field :occurred_at, :utc_datetime
    field :detected_at, :utc_datetime
    field :location, :string
    field :metadata, :map, default: %{}

    # Impact tracking
    field :financial_impact, :decimal
    field :operational_impact, :string
    field :reputational_impact, :string
    field :impact_areas, {:array, :string}

    # Response tracking
    field :immediate_actions, :string
    field :followup_actions, :string
    field :lessons_learned, :string
    field :prevention_measures, :string

    # Relationships
    belongs_to :project, Resolvinator.Projects.Project
    belongs_to :reporter, Resolvinator.Accounts.User, foreign_key: :reporter_id
    belongs_to :risk, Resolvinator.Risks.Risk
    belongs_to :mitigation, Resolvinator.Risks.Mitigation
    belongs_to :impact, Resolvinator.Risks.Impact

    many_to_many :affected_actors, Resolvinator.Actors.Actor,
      join_through: "event_actor_impacts"

    many_to_many :responsible_actors, Resolvinator.Actors.Actor,
      join_through: "event_actor_responsibilities"

    has_many :attachments, Resolvinator.Attachments.Attachment,
      foreign_key: :attachable_id,
      where: [attachable_type: "Event"]

    timestamps(type: :utc_datetime)
  end

  def changeset(event, attrs) do
    event
    |> cast(attrs, [
      :title, :description, :event_type, :severity,
      :occurred_at, :detected_at, :location, :metadata,
      :financial_impact, :operational_impact, :reputational_impact,
      :impact_areas, :immediate_actions, :followup_actions,
      :lessons_learned, :prevention_measures,
      :project_id, :reporter_id, :risk_id, :mitigation_id, :impact_id
    ])
    |> validate_required([
      :title, :description, :event_type, :severity,
      :occurred_at, :project_id, :reporter_id
    ])
    |> validate_inclusion(:event_type, @event_types)
    |> validate_inclusion(:severity, @severity_levels)
    |> foreign_key_constraint(:project_id)
    |> foreign_key_constraint(:reporter_id)
    |> foreign_key_constraint(:risk_id)
    |> foreign_key_constraint(:mitigation_id)
    |> foreign_key_constraint(:impact_id)
    |> validate_impact_areas()
  end

  defp validate_impact_areas(changeset) do
    case get_change(changeset, :impact_areas) do
      nil -> changeset
      areas ->
        if Enum.all?(areas, &(&1 in Resolvinator.Risks.ImpactBehavior.impact_areas())) do
          changeset
        else
          add_error(changeset, :impact_areas, "contains invalid impact area")
        end
    end
  end
end
