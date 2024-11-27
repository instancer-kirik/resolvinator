defmodule Resolvinator.Tech.TechKit do
  use Ecto.Schema
  import Ecto.Changeset

  schema "tech_kits" do
    field :name, :string
    field :description, :string
    field :kit_number, :string
    field :category, :string
    field :status, :string
    field :location, :string
    field :contents, {:array, :map}
    field :assembly_instructions, :string
    field :notes, :string
    field :search_vector, Resolvinator.Types.TsVector

    belongs_to :supplier, Resolvinator.Suppliers.Supplier
    many_to_many :items, Resolvinator.Tech.TechItem, join_through: "item_kits"
    many_to_many :parts, Resolvinator.Tech.TechPart, join_through: "part_kits"

    timestamps()
  end

  @required_fields ~w(name kit_number category status)a
  @optional_fields ~w(description location contents assembly_instructions notes)a
  @status_values ~w(available in_use maintenance incomplete retired)

  def changeset(tech_kit, attrs) do
    tech_kit
    |> cast(attrs, @required_fields ++ @optional_fields)
    |> validate_required(@required_fields)
    |> validate_inclusion(:status, @status_values)
    |> validate_contents()
    |> unique_constraint(:kit_number)
    |> foreign_key_constraint(:supplier_id)
  end

  defp validate_contents(changeset) do
    validate_change(changeset, :contents, fn :contents, contents ->
      if is_list(contents) and Enum.all?(contents, &valid_content_entry?/1) do
        []
      else
        [contents: "must be a list of valid content entries"]
      end
    end)
  end

  defp valid_content_entry?(%{
    "item_id" => item_id,
    "quantity" => quantity,
    "notes" => notes
  }) when is_integer(quantity) and quantity > 0 and is_binary(notes), do: true
  defp valid_content_entry?(_), do: false
end
