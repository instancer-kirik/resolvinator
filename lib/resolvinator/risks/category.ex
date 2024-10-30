defmodule Resolvinator.Risks.Category do
  use Ecto.Schema
  import Ecto.Changeset

  schema "risk_categories" do
    field :name, :string
    field :description, :string
    field :color, :string
    
    # Category-specific assessment criteria
    field :assessment_criteria, :map, default: %{
      "probability_factors" => [],
      "impact_factors" => [],
      "mitigation_guidelines" => [],
      "review_frequency_days" => 30
    }

    belongs_to :project, Resolvinator.Projects.Project
    belongs_to :creator, Resolvinator.Accounts.User
    has_many :risks, Resolvinator.Risks.Risk

    timestamps(type: :utc_datetime)
  end

  def changeset(category, attrs) do
    category
    |> cast(attrs, [:name, :description, :color, :assessment_criteria, 
                    :project_id, :creator_id])
    |> validate_required([:name, :project_id, :creator_id])
    |> validate_assessment_criteria()
    |> foreign_key_constraint(:project_id)
    |> foreign_key_constraint(:creator_id)
    |> unique_constraint([:name, :project_id])
  end

  defp validate_assessment_criteria(changeset) do
    case get_change(changeset, :assessment_criteria) do
      nil -> changeset
      criteria ->
        if valid_criteria?(criteria) do
          changeset
        else
          add_error(changeset, :assessment_criteria, "invalid criteria structure")
        end
    end
  end

  defp valid_criteria?(criteria) do
    # Implement criteria validation logic
    true
  end
end 