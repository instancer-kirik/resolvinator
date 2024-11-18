defmodule Resolvinator.Risks.Category do
  use Resolvinator.Content.ContentBehavior,
    type_name: :risk_category,
    table_name: "risk_categories",
    relationship_table: "risk_category_relationships",
    description_table: "risk_category_descriptions",
    relationship_keys: [risk_category_id: :id, related_risk_category_id: :id],
    description_keys: [risk_category_id: :id, description_id: :id],
    additional_schema: [
      fields: [
        # Original Category fields
        color: :string,
        
        # Assessment criteria
        assessment_criteria: {:map, default: %{
          "probability_factors" => [],
          "impact_factors" => [],
          "mitigation_guidelines" => [],
          "review_frequency_days" => 30
        }},
        
        # Tracking fields
        hidden: {:boolean, default: false},
        hidden_at: :utc_datetime,
        deleted_at: :utc_datetime
      ],
      relationships: [
        belongs_to: [
          hidden_by: [module: Resolvinator.Accounts.User]
        ],
        has_many: [
          risks: [module: Resolvinator.Risks.Risk]
        ],
        many_to_many: [
          related_categories: [
            module: Resolvinator.Risks.Category,
            join_through: "risk_category_relationships",
            join_keys: [risk_category_id: :id, related_risk_category_id: :id]
          ]
        ]
      ]
    ]

  @doc """
  Creates a changeset for the risk category.
  """
  def changeset(category, attrs) do
    category
    |> base_changeset(attrs)
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