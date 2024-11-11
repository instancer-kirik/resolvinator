defmodule Resolvinator.Risks.Category do
  use Ecto.Schema
  import Ecto.Changeset

  schema "risk_categories" do
    field :name, :string
    field :description, :string
    field :color, :string
    field :status, :string, default: "active"
    
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

    field :hidden, :boolean, default: false
    field :hidden_at, :utc_datetime
    belongs_to :hidden_by, Resolvinator.Accounts.User
    field :deleted_at, :utc_datetime

    timestamps(type: :utc_datetime)
  end

  def changeset(category, attrs) do
    category
    |> cast(attrs, [:name, :description, :color, :status, :assessment_criteria, 
                    :project_id, :creator_id, :hidden, :hidden_at, :hidden_by_id, :deleted_at])
    |> validate_required([:name, :project_id, :creator_id])
    |> validate_inclusion(:status, ["active", "inactive", "archived"])
    |> validate_assessment_criteria()
    |> foreign_key_constraint(:project_id)
    |> foreign_key_constraint(:creator_id)
    |> foreign_key_constraint(:hidden_by_id)
    |> unique_constraint([:name, :project_id, :hidden])
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

  defp valid_criteria?(_criteria) do
    # Implement criteria validation logic
    true
  end

  # Add helper functions for hiding/unhiding
  def hide(category, user_id) do
    category
    |> changeset(%{
      hidden: true,
      hidden_at: DateTime.utc_now(),
      hidden_by_id: user_id
    })
  end

  def unhide(category) do
    category
    |> changeset(%{
      hidden: false,
      hidden_at: nil,
      hidden_by_id: nil
    })
  end
end 