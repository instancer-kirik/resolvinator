defmodule Resolvinator.Tech.TechPart do
  use Ecto.Schema
  import Ecto.Changeset

  schema "tech_parts" do
    field :name, :string
    field :description, :string
    field :part_number, :string
    field :category, :string
    field :manufacturer, :string
    field :cost, :decimal
    field :quantity, :integer
    field :min_quantity, :integer
    field :location, :string
    field :specifications, :map
    field :search_vector, Resolvinator.Types.TsVector

    belongs_to :supplier, Resolvinator.Suppliers.Supplier
    many_to_many :items, Resolvinator.Tech.TechItem, join_through: "item_parts"
    many_to_many :kits, Resolvinator.Tech.TechKit, join_through: "part_kits"

    timestamps()
  end

  @required_fields ~w(name part_number category)a
  @optional_fields ~w(description manufacturer cost quantity min_quantity location specifications)a

  def changeset(tech_part, attrs) do
    tech_part
    |> cast(attrs, @required_fields ++ @optional_fields)
    |> validate_required(@required_fields)
    |> validate_number(:quantity, greater_than_or_equal_to: 0)
    |> validate_number(:min_quantity, greater_than_or_equal_to: 0)
    |> validate_specifications()
    |> unique_constraint(:part_number)
    |> foreign_key_constraint(:supplier_id)
  end

  defp validate_specifications(changeset) do
    validate_change(changeset, :specifications, fn :specifications, specs ->
      case validate_map_structure(specs) do
        :ok -> []
        {:error, reason} -> [specifications: reason]
      end
    end)
  end

  defp validate_map_structure(map) when is_map(map), do: :ok
  defp validate_map_structure(_), do: {:error, "must be a map"}
end
