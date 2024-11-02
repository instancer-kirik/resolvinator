defmodule Resolvinator.Suppliers.Catalog do
  use Ecto.Schema
  import Ecto.Changeset

  schema "supplier_catalogs" do
    field :name, :string
    field :description, :string
    field :effective_date, :date
    field :expiry_date, :date
    field :status, :string, default: "active"
    field :items, {:array, :map}  # Array of catalog items
    field :pricing_type, :string  # "fixed", "dynamic", "negotiated"
    field :currency, :string
    field :metadata, :map, default: %{}

    belongs_to :supplier, Resolvinator.Suppliers.Supplier
    belongs_to :creator, Resolvinator.Accounts.User

    timestamps(type: :utc_datetime)
  end

  def changeset(catalog, attrs) do
    catalog
    |> cast(attrs, [:name, :description, :effective_date, :expiry_date, 
                    :status, :items, :pricing_type, :currency, :metadata,
                    :supplier_id, :creator_id])
    |> validate_required([:name, :effective_date, :supplier_id])
    |> validate_inclusion(:status, ~w(active inactive archived))
    |> validate_inclusion(:pricing_type, ~w(fixed dynamic negotiated))
    |> validate_date_range()
    |> foreign_key_constraint(:supplier_id)
    |> foreign_key_constraint(:creator_id)
  end

  defp validate_date_range(changeset) do
    case {get_field(changeset, :effective_date), get_field(changeset, :expiry_date)} do
      {effective, expiry} when not is_nil(effective) and not is_nil(expiry) ->
        if Date.compare(effective, expiry) == :gt do
          add_error(changeset, :expiry_date, "must be after effective date")
        else
          changeset
        end
      _ ->
        changeset
    end
  end
end