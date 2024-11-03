defmodule Resolvinator.Resources.Resource do
  use Ecto.Schema
  import Ecto.Changeset

  schema "resources" do
    field :name, :string
    field :type, :string
    field :unit, :string
    field :description, :string
    field :metadata, :map
    field :quantity, :decimal
    field :cost_per_unit, :decimal
    field :availability_status, :string
    field :creator_id, :id
    field :project_id, :id

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(resource, attrs) do
    resource
    |> cast(attrs, [:name, :type, :description, :quantity, :unit, :cost_per_unit, :availability_status, :metadata])
    |> validate_required([:name, :type, :description, :quantity, :unit, :cost_per_unit, :availability_status])
  end
end
