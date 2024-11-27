defmodule Resolvinator.Risks.Risk do
  use Resolvinator.Schema
  import Ecto.Changeset
  alias Acts.User
  alias Resolvinator.Projects.Project
  alias Resolvinator.Risks.{Category, Mitigation, Impact}
  alias Resolvinator.Actors.Actor
  alias Resolvinator.Resources.{Resource, Requirement}
  alias Resolvinator.Rewards.Reward

  schema "risks" do
    field :title, :string
    field :description, :string
    field :status, :string, default: "identified"
    field :probability, :string
    field :impact_level, :string
    field :risk_score, :decimal
    field :notes, :string
    field :metadata, :map, default: %{}

    belongs_to :project, Project
    belongs_to :category, Category
    belongs_to :creator, User

    has_many :mitigations, Mitigation
    has_many :impacts, Impact
    has_many :requirements, Requirement
    has_many :rewards, Reward

    many_to_many :affected_actors, Actor,
      join_through: "actor_risk_relationships",
      join_keys: [risk_id: :id, actor_id: :id]

    many_to_many :resources, Resource,
      join_through: "risk_resources",
      join_keys: [risk_id: :id, resource_id: :id]

    timestamps(type: :utc_datetime)
  end

  def changeset(risk, attrs) do
    risk
    |> base_changeset(attrs)
    |> cast(attrs, [:title, :description, :status, :probability, :impact_level, :risk_score, :notes,
                    :project_id, :category_id, :creator_id])
    |> validate_required([:creator_id, :project_id])
    |> calculate_priority()
    |> apply_ai_validations()
    |> foreign_key_constraint(:creator_id)
    |> foreign_key_constraint(:project_id)
    |> foreign_key_constraint(:category_id)
  end

  defp calculate_priority(changeset) do
    with {:ok, probability} <- fetch_change(changeset, :probability),
         {:ok, impact_level} <- fetch_change(changeset, :impact_level) do
      risk_score = determine_priority(probability, impact_level)
      put_change(changeset, :risk_score, risk_score)
    else
      :error -> changeset
    end
  end

  defp determine_priority(probability, impact_level) do
    # Assuming you have access to a project context or a default project
    project = get_default_project()
    {_, risk_score} = Resolvinator.Risks.RiskMatrix.calculate_risk_score(project, probability, impact_level)
    risk_score
  end

  defp get_default_project do
    # Implement logic to retrieve a default project or context
    # This is a placeholder function
  end

  defp apply_ai_validations(changeset) do
    if Application.get_env(:resolvinator, :enable_ai_validations, false) do
      schema_info = %{
        schema: __schema__(:fields) |> Enum.map(&{&1, __schema__(:type, &1)}) |> Map.new(),
        framework: "ecto",
        include_documentation: true
      }

      case Resolvinator.AI.FabricClient.generate_validations(schema_info) do
        {:ok, validations} ->
          apply_generated_validations(changeset, validations)
        {:error, _} ->
          # Fallback to default validations
          apply_default_validations(changeset)
      end
    else
      # Skip AI validations entirely
      apply_default_validations(changeset)
    end
  end

  defp apply_default_validations(changeset) do
    changeset
    |> validate_required([:title, :description, :probability, :impact_level, :status])
    |> validate_length(:title, min: 3, max: 255)
    |> validate_length(:description, min: 10, max: 1000)
  end

  defp apply_generated_validations(changeset, validations) do
    changeset
    |> validate_required(validations.required)
    |> validate_inclusion(:impact_level, validations.inclusion.impact_level)
    |> validate_inclusion(:probability, validations.inclusion.probability)
    |> validate_inclusion(:status, validations.inclusion.status)
    |> validate_length(:title, validations.length.title)
    |> validate_length(:description, validations.length.description)
  end
end
