defmodule Resolvinator.Content.Advantage do
  use Flint.Schema
  alias Flint.Schema
  import Ecto.Changeset
  import Ecto.Query

  use Resolvinator.Content.ContentBehavior,
    type_name: :advantage,
    table_name: "advantages",
    relationship_table: "advantage_relationships",
    description_table: "advantage_descriptions",
    relationship_keys: [advantage_id: :id, related_advantage_id: :id],
    description_keys: [advantage_id: :id, description_id: :id]

  def changeset(advantage, attrs) do
    advantage
    |> base_changeset(attrs)
  end
end

defmodule Resolvinator.Content.AdvantageDescription do
  use Resolvinator.Content.ContentDescription,
    table_name: "advantage_descriptions",
    content_type: :advantage,
    content_module: Resolvinator.Content.Advantage,
    foreign_key: :advantage_id
end
