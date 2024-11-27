defmodule Resolvinator.Resources.Resource do
  use Ecto.Schema
  import Ecto.Changeset

  schema "resources" do
    field :name, :string
    field :type, :string
    field :unit, :string
    field :description, :string
    field :metadata, :map, default: %{}
    field :quantity, :decimal
    field :cost_per_unit, :decimal
    field :availability_status, :string
    
    belongs_to :creator, Acts.User, type: :binary_id
    belongs_to :project, Resolvinator.Projects.Project, type: :binary_id
    
    has_many :rewards, Resolvinator.Rewards.Reward
    has_many :allocations, Resolvinator.Resources.Allocation
    has_many :requirements, Resolvinator.Resources.Requirement

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(resource, attrs) do
    resource
    |> cast(attrs, [:name, :type, :description, :quantity, :unit, :cost_per_unit, 
                   :availability_status, :metadata, :creator_id, :project_id])
    |> validate_required([:name, :type, :description, :quantity, :unit, 
                        :cost_per_unit, :availability_status])
    |> foreign_key_constraint(:creator_id)
    |> foreign_key_constraint(:project_id)
  end
end
