defmodule Resolvinator.Suppliers.Supplier do
  use Resolvinator.Schema
  import Ecto.Changeset
  alias VES.Accounts.User
  alias Resolvinator.Suppliers.{Contact, Catalog}
  alias Resolvinator.Resources.InventorySource

  schema "suppliers" do
    field :name, :string
    field :description, :string
    field :status, :string, default: "active"
    field :api_endpoint, :string
    field :api_key, :string
    field :integration_type, :string  # "api", "catalog", "manual"
    field :metadata, :map

    belongs_to :creator, User
    has_many :contacts, Contact
    has_many :catalogs, Catalog
    has_many :sources, InventorySource
    
    timestamps(type: :utc_datetime)
  end 

  def changeset(supplier, attrs) do
    supplier
    |> cast(attrs, [:name, :description, :status, :api_endpoint, 
                    :api_key, :integration_type, :metadata])
    |> validate_required([:name, :status])
  end
end 