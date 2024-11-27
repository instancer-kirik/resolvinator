defmodule Resolvinator.Resources.Allocation do
  use Ecto.Schema
  import Ecto.Changeset

  @type_values ~w(budget staff equipment time other)

  schema "resource_allocations" do
    field :name, :string
    field :type, :string
    field :amount, :decimal
    field :unit, :string
    field :start_date, :date
    field :end_date, :date
    field :status, :string
    field :notes, :string

    belongs_to :risk, Resolvinator.Risks.Risk
    belongs_to :mitigation, Resolvinator.Risks.Mitigation
    belongs_to :creator, Acts.User
    belongs_to :requirement, Resolvinator.Resources.Requirement

    timestamps(type: :utc_datetime)
  end

  def changeset(allocation, attrs) do
    allocation
    |> cast(attrs, [:name, :type, :amount, :unit, :start_date, :end_date, 
                    :status, :notes, :risk_id, :mitigation_id, :creator_id, :requirement_id])
    |> validate_required([:name, :type, :amount, :creator_id])
    |> validate_inclusion(:type, @type_values)
    |> foreign_key_constraint(:risk_id)
    |> foreign_key_constraint(:mitigation_id)
    |> foreign_key_constraint(:creator_id)
    |> foreign_key_constraint(:requirement_id)
    |> check_constraint(:resource_owner, 
        name: :must_belong_to_risk_or_mitigation,
        message: "must belong to either a risk or a mitigation")
  end 
end
