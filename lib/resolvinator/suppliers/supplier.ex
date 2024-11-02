defmodule Resolvinator.Suppliers.Supplier do
  use Ecto.Schema
  import Ecto.Changeset

  schema "suppliers" do
    field :name, :string
    field :code, :string
    field :type, :string
    field :status, :string
    field :rating, :decimal
    field :payment_terms, :string
    field :lead_time_days, :integer
    field :minimum_order, :decimal
    field :website, :string
    field :api_endpoint, :string
    field :api_key, :string
    field :integration_type, :string  # "api", "catalog", "manual"
    field :metadata, :map

    has_many :contacts, Resolvinator.Suppliers.Contact
    has_many :catalogs, Resolvinator.Suppliers.Catalog
    has_many :sources, Resolvinator.Resources.InventorySource
    
    timestamps(type: :utc_datetime)
  end 

  def changeset(supplier, attrs) do
    supplier
    |> cast(attrs, [:name, :code, :type, :status, :rating, :payment_terms, 
                    :lead_time_days, :minimum_order, :website, :api_endpoint, 
                    :api_key, :integration_type, :metadata])
    |> validate_required([:name, :code, :type, :status])
  end
end 