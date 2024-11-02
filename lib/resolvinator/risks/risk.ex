defmodule Resolvinator.Risks.Risk do
  use Ecto.Schema
  import Ecto.Changeset
  
  @priority_values ~w(low medium high critical)
  @status_values ~w(identified analyzing mitigating resolved closed)
  @probability_values ~w(rare unlikely possible likely certain)
  @impact_values ~w(negligible minor moderate major severe)
  
  schema "risks" do
    field :name, :string
    field :description, :string
    field :probability, :string
    field :impact, :string
    field :priority, :string    # Could be calculated from probability and impact
    field :status, :string
    field :mitigation_status, :string
    field :detection_date, :date
    field :review_date, :date
    
    # Core relationships
    belongs_to :creator, Resolvinator.Accounts.User
    belongs_to :project, Resolvinator.Projects.Project
    belongs_to :risk_category, Resolvinator.Risks.Category
    
    # Risk relationships
    many_to_many :related_risks, __MODULE__, 
      join_through: "risk_relationships",
      join_keys: [risk_id: :id, related_risk_id: :id]
    
    # Impact and mitigation tracking
    has_many :impacts, Resolvinator.Risks.Impact
    has_many :mitigations, Resolvinator.Risks.Mitigation
    
    # Actor relationships (replaces organization)
    many_to_many :affected_actors, Resolvinator.Actors.Actor,
      join_through: "actor_risk_impacts"
    many_to_many :responsible_actors, Resolvinator.Actors.Actor,
      join_through: "actor_risk_responsibilities"
    
    # Resource tracking
    has_many :resource_allocations, Resolvinator.Resources.Allocation

    timestamps(type: :utc_datetime)
  end

  def changeset(risk, attrs) do
    risk
    |> cast(attrs, [:name, :description, :probability, :impact, :priority, 
                    :status, :mitigation_status, :detection_date, 
                    :review_date, :creator_id, :project_id, :risk_category_id])
    |> validate_required([:name, :description, :probability, :impact, 
                         :status, :creator_id, :project_id])
    |> validate_inclusion(:probability, @probability_values)
    |> validate_inclusion(:impact, @impact_values)
    |> validate_inclusion(:priority, @priority_values)
    |> validate_inclusion(:status, @status_values)
    |> calculate_priority()
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
    project = get_default_project() # Replace with actual project retrieval logic

    {_, priority} = Resolvinator.Risks.RiskMatrix.calculate_risk_score(project, probability, impact)
    priority
  end

  defp get_default_project do
    # Implement logic to retrieve a default project or context
    # This is a placeholder function
  end
end
