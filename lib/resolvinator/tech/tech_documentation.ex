defmodule Resolvinator.Tech.TechDocumentation do
  use Ecto.Schema
  import Ecto.Changeset

  schema "tech_documentation" do
    field :title, :string
    field :description, :string
    field :content, :string
    field :doc_type, :string
    field :version, :string
    field :author, :string
    field :tags, {:array, :string}
    field :metadata, :map
    field :search_vector, Resolvinator.Types.TsVector

    belongs_to :created_by, Acts.User, type: :binary_id
    belongs_to :last_updated_by, Acts.User, type: :binary_id
    many_to_many :items, Resolvinator.Tech.TechItem, join_through: "item_documentation"

    timestamps()
  end

  @required_fields ~w(title content doc_type)a
  @optional_fields ~w(description version author tags metadata)a
  @doc_types ~w(manual guide procedure specification datasheet)

  def changeset(tech_documentation, attrs) do
    tech_documentation
    |> cast(attrs, @required_fields ++ @optional_fields)
    |> validate_required(@required_fields)
    |> validate_inclusion(:doc_type, @doc_types)
    |> validate_metadata()
    |> validate_tags()
    |> foreign_key_constraint(:created_by_id)
    |> foreign_key_constraint(:last_updated_by_id)
  end

  defp validate_metadata(changeset) do
    validate_change(changeset, :metadata, fn :metadata, metadata ->
      case validate_map_structure(metadata) do
        :ok -> []
        {:error, reason} -> [metadata: reason]
      end
    end)
  end

  defp validate_tags(changeset) do
    validate_change(changeset, :tags, fn :tags, tags ->
      if is_list(tags) and Enum.all?(tags, &is_binary/1) do
        []
      else
        [tags: "must be a list of strings"]
      end
    end)
  end

  defp validate_map_structure(map) when is_map(map), do: :ok
  defp validate_map_structure(_), do: {:error, "must be a map"}
end
