defmodule Resolvinator.Etymology.Term do
  use Resolvinator.Content.ContentBehavior,
    type_name: :term,
    table_name: "etymology_terms",
    relationship_table: "term_relationships",
    description_table: "term_descriptions",
    relationship_keys: [term_id: :id, related_term_id: :id],
    description_keys: [term_id: :id, description_id: :id],
    additional_schema: [
      fields: [
        # Etymology fields
        etymology: :string,
        language_origin: :string,
        first_known_use: :string,
        pronunciation: :string,
        part_of_speech: :string,
        
        # Definition fields
        definitions: {:array, :string},
        usage_examples: {:array, :string},
        
        # Disambiguation fields
        disambiguations: {:array, :map},  # [{term: string, description: string, context: string}]
        
        # Domain-specific fields
        domain_contexts: {:array, :string},  # e.g., ["technical", "business", "risk"]
        domain_specific_definitions: :map,  # %{"risk" => "definition in risk context", ...}
        
        # Tracking fields
        search_vector: Resolvinator.Types.TsVector
      ],
      relationships: [
        many_to_many: [
          synonyms: [
            module: Resolvinator.Etymology.Term,
            join_through: "term_synonyms",
            join_keys: [term_id: :id, synonym_id: :id]
          ],
          antonyms: [
            module: Resolvinator.Etymology.Term,
            join_through: "term_antonyms",
            join_keys: [term_id: :id, antonym_id: :id]
          ],
          related_concepts: [
            module: Resolvinator.Etymology.Term,
            join_through: "term_concept_relationships",
            join_keys: [term_id: :id, related_term_id: :id]
          ]
        ]
      ]
    ]

  @parts_of_speech ~w(noun verb adjective adverb preposition conjunction interjection)
  @domain_contexts ~w(technical business risk general legal financial)

  def changeset(term, attrs) do
    term
    |> base_changeset(attrs)
    |> cast(attrs, [
      :etymology,
      :language_origin,
      :first_known_use,
      :pronunciation,
      :part_of_speech,
      :definitions,
      :usage_examples,
      :disambiguations,
      :domain_contexts,
      :domain_specific_definitions
    ])
    |> validate_required([
      :part_of_speech,
      :definitions
    ])
    |> validate_inclusion(:part_of_speech, @parts_of_speech)
    |> validate_domain_contexts()
    |> validate_disambiguations()
    |> validate_definitions()
  end

  defp validate_domain_contexts(changeset) do
    case get_change(changeset, :domain_contexts) do
      nil -> changeset
      contexts ->
        if Enum.all?(contexts, &(&1 in @domain_contexts)) do
          changeset
        else
          add_error(changeset, :domain_contexts, "invalid domain context")
        end
    end
  end

  defp validate_disambiguations(changeset) do
    case get_change(changeset, :disambiguations) do
      nil -> changeset
      disambiguations ->
        if valid_disambiguations?(disambiguations) do
          changeset
        else
          add_error(changeset, :disambiguations, "invalid disambiguation structure")
        end
    end
  end

  defp valid_disambiguations?(disambiguations) when is_list(disambiguations) do
    Enum.all?(disambiguations, &valid_disambiguation?/1)
  end
  defp valid_disambiguations?(_), do: false

  defp valid_disambiguation?(%{"term" => term, "description" => desc, "context" => ctx})
    when is_binary(term) and is_binary(desc) and is_binary(ctx), do: true
  defp valid_disambiguation?(_), do: false

  defp validate_definitions(changeset) do
    case get_change(changeset, :definitions) do
      nil -> changeset
      definitions when is_list(definitions) and length(definitions) > 0 -> changeset
      _ -> add_error(changeset, :definitions, "must have at least one definition")
    end
  end
end