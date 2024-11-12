defmodule Resolvinator.Projects.Project do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

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
      # Project metadata
      "metadata" => %{
        "domain" => nil,
        "target_audience" => nil,
        "version" => "0.1.0",
        "license" => nil,
        "repository_url" => nil,
        "documentation_url" => nil,
        "issue_tracker_url" => nil,
        "keywords" => [],
        "categories" => [],
        "visibility" => "private",
        "language" => nil,
        "framework" => nil,
        "dependencies" => %{},
        "dev_dependencies" => %{},
        "contributors" => [],
        "maintainers" => []
      },

      # Development environment
      "development" => %{
        "build_command" => nil,
        "run_command" => nil,
        "test_command" => nil,
        "lint_command" => nil,
        "registered_scripts" => [],
        "file_extensions" => [".py", ".json", ".yml"],
        "excluded_dirs" => ["__pycache__", ".git", "venv"],
        "workspace_path" => nil,
        "environment_variables" => %{},
        "required_tools" => [],
        "minimum_tool_versions" => %{}
      },

      # Risk configuration
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
      
      # Notification and monitoring
      "notification_preferences" => %{
        "high_risk_threshold" => 12,
        "review_period_days" => 30,
        "alert_channels" => [],
        "monitoring_intervals" => %{
          "risk_review" => "30d",
          "dependency_check" => "7d",
          "security_scan" => "14d"
        }
      },

      # Integration settings
      "integrations" => %{
        "ci_cd" => %{
          "provider" => nil,
          "config_path" => nil,
          "triggers" => []
        },
        "cloud_services" => %{},
        "api_keys" => %{},
        "webhooks" => []
      },

      # Quality metrics
      "quality_metrics" => %{
        "test_coverage_target" => 80,
        "max_complexity" => 10,
        "style_guide" => nil,
        "performance_targets" => %{},
        "security_requirements" => []
      }
    }

    # Relationships
    belongs_to :creator, Resolvinator.Accounts.User, type: :binary_id
    has_many :risks, Resolvinator.Risks.Risk
    has_many :risk_categories, Resolvinator.Risks.Category
    
    many_to_many :team_members, Resolvinator.Accounts.User,
      join_through: "project_members",
      join_keys: [project_id: :id, user_id: :id]
    
    many_to_many :actors, Resolvinator.Actors.Actor,
      join_through: "project_actors"

    # Add systems relationship
    has_many :systems, Resolvinator.Systems.System

    # Add resources relationship
    has_many :resources, Resolvinator.Resources.Resource
    has_many :rewards, Resolvinator.Rewards.Reward

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