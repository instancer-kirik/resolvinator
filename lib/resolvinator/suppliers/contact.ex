defmodule Resolvinator.Suppliers.Contact do
  use Ecto.Schema
  import Ecto.Changeset

  schema "supplier_contacts" do
    field :name, :string
    field :email, :string
    field :phone, :string
    field :role, :string
    field :primary, :boolean, default: false
    field :notes, :string
    field :status, :string, default: "active"
    field :metadata, :map, default: %{}

    belongs_to :supplier, Resolvinator.Suppliers.Supplier
    belongs_to :creator, Resolvinator.Accounts.User

    timestamps(type: :utc_datetime)
  end

  def changeset(contact, attrs) do
    contact
    |> cast(attrs, [:name, :email, :phone, :role, :primary, :notes, 
                    :status, :metadata, :supplier_id, :creator_id])
    |> validate_required([:name, :email, :role, :supplier_id])
    |> validate_format(:email, ~r/^[^\s]+@[^\s]+$/)
    |> unique_constraint([:email, :supplier_id])
    |> foreign_key_constraint(:supplier_id)
    |> foreign_key_constraint(:creator_id)
  end 
end 