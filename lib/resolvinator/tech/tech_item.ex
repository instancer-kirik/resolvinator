defmodule Resolvinator.Tech.TechItem do
  use Ecto.Schema
  import Ecto.Changeset

  schema "tech_items" do
    field :name, :string
    field :description, :string
    field :category, :string
    field :status, :string
    field :manufacturer, :string
    field :model, :string
    field :serial_number, :string
    field :purchase_date, :date
    field :warranty_expiry, :date
    field :specifications, :map
    field :maintenance_history, {:array, :map}
    field :search_vector, Resolvinator.Types.TsVector

    belongs_to :supplier, Resolvinator.Suppliers.Supplier
    belongs_to :owner, Acts.User, type: :binary_id
    belongs_to :assigned_to, Acts.User, type: :binary_id
    belongs_to :last_maintained_by, Acts.User, type: :binary_id

    has_many :activities, Resolvinator.Tech.TechItemActivity
    many_to_many :parts, Resolvinator.Tech.TechPart, join_through: "item_parts"
    many_to_many :kits, Resolvinator.Tech.TechKit, join_through: "item_kits"
    many_to_many :documentation, Resolvinator.Tech.TechDocumentation, join_through: "item_documentation"

    timestamps()
  end

  @required_fields ~w(name category status)a
  @optional_fields ~w(description manufacturer model serial_number purchase_date warranty_expiry specifications maintenance_history)a
  @status_values ~w(available in_use maintenance repair retired)

  def changeset(tech_item, attrs) do
    tech_item
    |> cast(attrs, @required_fields ++ @optional_fields)
    |> validate_required(@required_fields)
    |> validate_inclusion(:status, @status_values)
    |> validate_specifications()
    |> validate_maintenance_history()
    |> foreign_key_constraint(:supplier_id)
    |> foreign_key_constraint(:owner_id)
    |> foreign_key_constraint(:assigned_to_id)
    |> foreign_key_constraint(:last_maintained_by_id)
  end

  defp validate_specifications(changeset) do
    validate_change(changeset, :specifications, fn :specifications, specs ->
      case validate_map_structure(specs) do
        :ok -> []
        {:error, reason} -> [specifications: reason]
      end
    end)
  end

  defp validate_maintenance_history(changeset) do
    validate_change(changeset, :maintenance_history, fn :maintenance_history, history ->
      if is_list(history) and Enum.all?(history, &valid_maintenance_entry?/1) do
        []
      else
        [maintenance_history: "must be a list of valid maintenance entries"]
      end
    end)
  end

  defp valid_maintenance_entry?(%{
    "date" => date,
    "type" => type,
    "description" => description
  }) when is_binary(date) and is_binary(type) and is_binary(description), do: true
  defp valid_maintenance_entry?(_), do: false

  defp validate_map_structure(map) when is_map(map), do: :ok
  defp validate_map_structure(_), do: {:error, "must be a map"}
end
