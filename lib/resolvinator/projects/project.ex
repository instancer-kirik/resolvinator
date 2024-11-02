defmodule Resolvinator.Projects.Project do
  use Ecto.Schema
  import Ecto.Changeset

  @status_values ~w(planning active on_hold completed archived)
  @risk_appetite_values ~w(averse minimal cautious flexible aggressive)

  schema "projects" do
    field :name, :string
    field :description, :string
    field :status, :string, default: "planning"
    field :risk_appetite, :string
    field :start_date, :date
    field :target_date, :date
    field :completion_date, :date
    
    # Project-specific settings
    field :settings, :map, default: %{
      "risk_matrix_config" => %{
        "probability_weights" => %{
          "rare" => 1,
          "unlikely" => 2,
          "possible" => 3,
          "likely" => 4,
          "certain" => 5
        },
        "impact_weights" => %{
          "negligible" => 1,
          "minor" => 2,
          "moderate" => 3,
          "major" => 4,
          "severe" => 5
        }
      },
      "notification_preferences" => %{
        "high_risk_threshold" => 12,
        "review_period_days" => 30
      }
    }

    # Relationships
    belongs_to :creator, Resolvinator.Accounts.User
    has_many :risks, Resolvinator.Risks.Risk
    has_many :risk_categories, Resolvinator.Risks.Category
    
    many_to_many :team_members, Resolvinator.Accounts.User,
      join_through: "project_members",
      join_keys: [project_id: :id, user_id: :id]
    
    many_to_many :actors, Resolvinator.Actors.Actor,
      join_through: "project_actors"

    timestamps(type: :utc_datetime)
  end

  def changeset(project, attrs) do
    project
    |> cast(attrs, [:name, :description, :status, :risk_appetite, 
                    :start_date, :target_date, :completion_date, 
                    :settings, :creator_id])
    |> validate_required([:name, :risk_appetite, :creator_id])
    |> validate_inclusion(:status, @status_values)
    |> validate_inclusion(:risk_appetite, @risk_appetite_values)
    |> validate_settings()
    |> foreign_key_constraint(:creator_id)
  end

  defp validate_settings(changeset) do
    case get_change(changeset, :settings) do
      nil -> changeset
      settings ->
        if valid_settings?(settings) do
          changeset
        else
          add_error(changeset, :settings, "invalid settings structure")
        end
    end
  end

  defp valid_settings?(_settings) do
    # Implement settings validation logic
    true
  end

  # Business Logic

  def risk_score(%__MODULE__{} = project, probability, impact) do
    weights = get_in(project.settings, ["risk_matrix_config"])
    p_weight = get_in(weights, ["probability_weights", probability]) || 1
    i_weight = get_in(weights, ["impact_weights", impact]) || 1
    p_weight * i_weight
  end

  def risk_threshold(%__MODULE__{} = project) do
    get_in(project.settings, ["notification_preferences", "high_risk_threshold"]) || 12
  end

  def needs_review?(%__MODULE__{} = project, risk) do
    review_period = get_in(project.settings, ["notification_preferences", "review_period_days"]) || 30
    last_review = risk.review_date || risk.detection_date
    
    Date.diff(Date.utc_today(), last_review) >= review_period
  end
end 