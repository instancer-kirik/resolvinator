defmodule Resolvinator.Tech do
  @moduledoc """
  The Tech context handles all tech-related functionality including items, parts,
  kits, and documentation management.
  """

  import Ecto.Query, warn: false
  alias Resolvinator.Repo
  alias Resolvinator.Tech.{TechItem, TechPart, TechKit, TechDocumentation, TechItemActivity}

  # Tech Items
  def list_tech_items(opts \\ []) do
    TechItem
    |> apply_filters(opts[:filters] || %{})
    |> apply_sorting(opts[:sort] || [asc: :name])
    |> Repo.all()
  end

  def get_tech_item!(id), do: Repo.get!(TechItem, id)

  def create_tech_item(attrs \\ %{}) do
    %TechItem{}
    |> TechItem.changeset(attrs)
    |> Repo.insert()
  end

  def update_tech_item(%TechItem{} = item, attrs) do
    item
    |> TechItem.changeset(attrs)
    |> Repo.update()
  end

  def delete_tech_item(%TechItem{} = item) do
    Repo.delete(item)
  end

  # Tech Parts
  def list_tech_parts(opts \\ []) do
    TechPart
    |> apply_filters(opts[:filters] || %{})
    |> apply_sorting(opts[:sort] || [asc: :name])
    |> Repo.all()
  end

  def get_tech_part!(id), do: Repo.get!(TechPart, id)

  def create_tech_part(attrs \\ %{}) do
    %TechPart{}
    |> TechPart.changeset(attrs)
    |> Repo.insert()
  end

  def update_tech_part(%TechPart{} = part, attrs) do
    part
    |> TechPart.changeset(attrs)
    |> Repo.update()
  end

  def delete_tech_part(%TechPart{} = part) do
    Repo.delete(part)
  end

  # Tech Kits
  def list_tech_kits(opts \\ []) do
    TechKit
    |> apply_filters(opts[:filters] || %{})
    |> apply_sorting(opts[:sort] || [asc: :name])
    |> Repo.all()
  end

  def get_tech_kit!(id), do: Repo.get!(TechKit, id)

  def create_tech_kit(attrs \\ %{}) do
    %TechKit{}
    |> TechKit.changeset(attrs)
    |> Repo.insert()
  end

  def update_tech_kit(%TechKit{} = kit, attrs) do
    kit
    |> TechKit.changeset(attrs)
    |> Repo.update()
  end

  def delete_tech_kit(%TechKit{} = kit) do
    Repo.delete(kit)
  end

  # Tech Documentation
  def list_tech_documentation(opts \\ []) do
    TechDocumentation
    |> apply_filters(opts[:filters] || %{})
    |> apply_sorting(opts[:sort] || [asc: :title])
    |> Repo.all()
  end

  def get_tech_documentation!(id), do: Repo.get!(TechDocumentation, id)

  def create_tech_documentation(attrs \\ %{}) do
    %TechDocumentation{}
    |> TechDocumentation.changeset(attrs)
    |> Repo.insert()
  end

  def update_tech_documentation(%TechDocumentation{} = doc, attrs) do
    doc
    |> TechDocumentation.changeset(attrs)
    |> Repo.update()
  end

  def delete_tech_documentation(%TechDocumentation{} = doc) do
    Repo.delete(doc)
  end

  # Tech Item Activities
  def list_tech_item_activities(item_id, opts \\ []) do
    TechItemActivity
    |> where([a], a.item_id == ^item_id)
    |> apply_filters(opts[:filters] || %{})
    |> apply_sorting(opts[:sort] || [desc: :inserted_at])
    |> Repo.all()
  end

  def create_tech_item_activity(attrs \\ %{}) do
    %TechItemActivity{}
    |> TechItemActivity.changeset(attrs)
    |> Repo.insert()
  end

  # Private Functions
  defp apply_filters(query, filters) do
    Enum.reduce(filters, query, fn
      {:search, term}, query when is_binary(term) and byte_size(term) > 0 ->
        where(query, [q], fragment("? @@ plainto_tsquery('english', ?)", q.search_vector, ^term))
      {field, value}, query when is_atom(field) and not is_nil(value) ->
        where(query, [q], field(q, ^field) == ^value)
      _, query -> query
    end)
  end

  defp apply_sorting(query, sort_fields) do
    order_by(query, ^sort_fields)
  end
end
