defmodule Resolvinator.Etymology do
  @moduledoc """
  Context for managing etymology and term definitions.
  """

  import Ecto.Query
  alias Resolvinator.Repo
  alias Resolvinator.Etymology.Term

  def list_terms(opts \\ []) do
    Term
    |> apply_filters(opts[:filters] || %{})
    |> apply_sorting(opts[:sort] || [asc: :name])
    |> Repo.all()
  end

  def get_term!(id), do: Repo.get!(Term, id)

  def create_term(attrs \\ %{}) do
    %Term{}
    |> Term.changeset(attrs)
    |> Repo.insert()
  end

  def update_term(%Term{} = term, attrs) do
    term
    |> Term.changeset(attrs)
    |> Repo.update()
  end

  def delete_term(%Term{} = term) do
    Repo.delete(term)
  end

  def change_term(%Term{} = term, attrs \\ %{}) do
    Term.changeset(term, attrs)
  end

  def search_terms(query, opts \\ []) do
    Term
    |> where([t], fragment("? @@ plainto_tsquery('english', ?)", t.search_vector, ^query))
    |> order_by([t], desc: fragment("ts_rank(?, plainto_tsquery('english', ?))", 
                                  t.search_vector, ^query))
    |> apply_filters(opts[:filters] || %{})
    |> Repo.all()
  end

  def get_term_by_name(name) do
    Repo.one(from t in Term, where: t.name == ^name)
  end

  def list_synonyms(term_id) do
    Term
    |> join(:inner, [t], s in "term_synonyms", on: s.term_id == ^term_id and s.synonym_id == t.id)
    |> Repo.all()
  end

  def list_antonyms(term_id) do
    Term
    |> join(:inner, [t], a in "term_antonyms", on: a.term_id == ^term_id and a.antonym_id == t.id)
    |> Repo.all()
  end

  def list_related_concepts(term_id) do
    Term
    |> join(:inner, [t], r in "term_concept_relationships", 
           on: r.term_id == ^term_id and r.related_term_id == t.id)
    |> Repo.all()
  end

  def get_domain_definition(term, domain) do
    term.domain_specific_definitions[domain] || List.first(term.definitions)
  end

  defp apply_filters(query, filters) do
    Enum.reduce(filters, query, fn
      {:part_of_speech, pos}, query ->
        where(query, [t], t.part_of_speech == ^pos)
      
      {:domain, domain}, query ->
        where(query, [t], ^domain in t.domain_contexts)
      
      {:language_origin, origin}, query ->
        where(query, [t], t.language_origin == ^origin)
      
      _, query -> query
    end)
  end

  defp apply_sorting(query, sort_opts) do
    order_by(query, ^sort_opts)
  end
end 