defmodule Resolvinator.Risks.Category do
  use Resolvinator.Schema
  import Ecto.Changeset
  alias Resolvinator.Acts.User
  alias Resolvinator.Projects.Project
  alias Resolvinator.Risks.Risk

  schema "risk_categories" do
    field :name, :string
    field :description, :string
    field :color, :string
    field :icon, :string
    field :status, :string, default: "active"
    field :metadata, :map, default: %{}

    field :assessment_criteria, {:map, default: %{
      "probability_factors" => [],
      "impact_factors" => [],
      "mitigation_guidelines" => [],
      "review_frequency_days" => 30
    }}

    field :hidden, {:boolean, default: false}
    field :hidden_at, :utc_datetime
    field :deleted_at, :utc_datetime

    belongs_to :project, Project
    belongs_to :creator, User
    belongs_to :parent_category, __MODULE__
    belongs_to :hidden_by, User

    has_many :risks, Risk
    has_many :subcategories, __MODULE__, foreign_key: :parent_category_id
    many_to_many :related_categories, __MODULE__, join_through: "risk_category_relationships", join_keys: [risk_category_id: :id, related_risk_category_id: :id]

    timestamps(type: :utc_datetime)
  end

  @doc """
  Creates a changeset for the risk category.
  """
  def changeset(category, attrs) do
    category
    |> cast(attrs, [
      :color,
      :assessment_criteria,
      :hidden,
      :hidden_at,
      :hidden_by_id,
      :deleted_at
    ])
    |> validate_required([:color])
    |> validate_assessment_criteria()
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

  defp valid_criteria?(%{
    "probability_factors" => factors,
    "impact_factors" => impacts,
    "mitigation_guidelines" => guidelines,
    "review_frequency_days" => days
  }) when is_list(factors) and is_list(impacts) and is_list(guidelines) and is_integer(days) do
    true
  end
  defp valid_criteria?(_), do: false

  # Soft delete functionality
  def soft_delete(category) do
    change(category, %{deleted_at: DateTime.utc_now()})
  end

  # Hide/unhide functionality
  def hide(category, user_id) do
    change(category, %{
      hidden: true,
      hidden_at: DateTime.utc_now(),
      hidden_by_id: user_id
    })
  end

  def unhide(category) do
    change(category, %{
      hidden: false,
      hidden_at: nil,
      hidden_by_id: nil
    })
  end
end