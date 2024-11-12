defmodule Resolvinator.Risks.Risk do
  use Flint.Schema
  use Resolvinator.Risks.RiskBehavior


  schema "risks" do
    # Define the common fields directly
    field :name, :string
    field :description, :string
    field :probability, :string
    field :impact, :string
    field :priority, :string
    field :status, :string
    field :metadata, :map, default: %{}

    # Core relationships
    belongs_to :creator, Resolvinator.Accounts.User
    belongs_to :project, Resolvinator.Projects.Project
    belongs_to :category, Resolvinator.Risks.Category, foreign_key: :risk_category_id

    # Risk relationships
    many_to_many :related_risks, __MODULE__,
      join_through: "risk_relationships",
      join_keys: [risk_id: :id, related_risk_id: :id]

    # Impact and mitigation tracking
    has_many :impacts, Resolvinator.Risks.Impact
    has_many :mitigations, Resolvinator.Risks.Mitigation

    # Actor relationships
    many_to_many :affected_actors, Resolvinator.Actors.Actor,
      join_through: "actor_risk_impacts"
    many_to_many :responsible_actors, Resolvinator.Actors.Actor,
      join_through: "actor_risk_responsibilities"

    # Resource tracking
    has_many :resource_allocations, Resolvinator.Resources.Allocation

    # Additional fields specific to Risk
    field :mitigation_status, :string
    field :detection_date, :date
    field :review_date, :date

    # Topic relationships (through generic content_topic_relationships)
    many_to_many :topics, Resolvinator.Topics.Topic,
      join_through: "content_topic_relationships",
      join_keys: [content_id: :id, topic_id: :id],
      join_where: [content_type: "risk"],
      on_replace: :delete

    timestamps(type: :utc_datetime)
  end

  def changeset(risk, attrs) do
    risk
    |> base_changeset(attrs)
    |> cast(attrs, [:mitigation_status, :detection_date, :review_date,
                    :creator_id, :project_id, :risk_category_id])
    |> validate_required([:creator_id, :project_id])
    |> calculate_priority()
    |> apply_ai_validations()
    |> foreign_key_constraint(:creator_id)
    |> foreign_key_constraint(:project_id)
    |> foreign_key_constraint(:risk_category_id)
  end

  defp calculate_priority(changeset) do
    with {:ok, probability} <- fetch_change(changeset, :probability),
         {:ok, impact} <- fetch_change(changeset, :impact) do
      priority = determine_priority(probability, impact)
      put_change(changeset, :priority, priority)
    else
      :error -> changeset
    end
  end

  defp determine_priority(probability, impact) do
    # Assuming you have access to a project context or a default project
    project = get_default_project()
    {_, priority} = Resolvinator.Risks.RiskMatrix.calculate_risk_score(project, probability, impact)
    priority
  end

  defp get_default_project do
    # Implement logic to retrieve a default project or context
    # This is a placeholder function
  end

  defp apply_ai_validations(changeset) do
    case Resolvinator.AI.FabricEngineering.generate_validations(__MODULE__) do
      {:ok, validations} ->
        apply_generated_validations(changeset, validations)
      {:error, _} ->
        # Fallback to default validations if AI service is unavailable
        changeset
    end
  end

  defp apply_generated_validations(changeset, validations) do
    Enum.reduce(validations, changeset, fn validation, acc ->
      case validation do
        %{"field" => field, "type" => "format", "pattern" => pattern} ->
          validate_format(acc, String.to_atom(field), ~r/#{pattern}/)
        %{"field" => field, "type" => "length", "min" => min, "max" => max} ->
          validate_length(acc, String.to_atom(field), min: min, max: max)
        _ ->
          acc
      end
    end)
  end
end
