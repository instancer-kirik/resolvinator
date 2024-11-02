defmodule Resolvinator.Resources.Requirement do
  use Ecto.Schema
  import Ecto.Changeset

  @type_values ~w(budget staff equipment inventory time other)
  @priority_values ~w(low medium high critical)
  @status_values ~w(draft requested approved denied allocated in_use completed cancelled)

  schema "resource_requirements" do
    field :name, :string
    field :type, :string
    field :priority, :string
    field :estimated_amount, :decimal
    field :unit, :string
    field :needed_by_date, :date
    field :duration_days, :integer
    field :status, :string, default: "draft"
    field :justification, :string
    field :notes, :string
    
    # Inventory specific fields
    field :inventory_item_id, :integer
    field :quantity_needed, :integer
    field :quantity_allocated, :integer, default: 0
    field :reorder_threshold, :integer
    field :is_consumable, :boolean, default: false

    belongs_to :project, Resolvinator.Projects.Project
    belongs_to :risk, Resolvinator.Risks.Risk
    belongs_to :mitigation, Resolvinator.Risks.Mitigation
    belongs_to :responsible_actor, Resolvinator.Actors.Actor
    belongs_to :creator, Resolvinator.Accounts.User
    
    has_many :allocations, Resolvinator.Resources.Allocation

    timestamps(type: :utc_datetime)
  end

  def changeset(requirement, attrs) do
    requirement
    |> cast(attrs, [
      :name, :type, :priority, :estimated_amount, :unit,
      :needed_by_date, :duration_days, :status, :justification, :notes,
      :inventory_item_id, :quantity_needed, :quantity_allocated,
      :reorder_threshold, :is_consumable,
      :project_id, :risk_id, :mitigation_id, :responsible_actor_id, :creator_id
    ])
    |> validate_required([
      :name, :type, :priority, :status, :creator_id,
      :estimated_amount
    ])
    |> validate_inclusion(:type, @type_values)
    |> validate_inclusion(:priority, @priority_values)
    |> validate_inclusion(:status, @status_values)
    |> validate_number(:estimated_amount, greater_than: 0)
    |> validate_number(:quantity_needed, greater_than: 0)
    |> validate_number(:quantity_allocated, greater_than_or_equal_to: 0)
    |> validate_inventory_fields()
    |> foreign_key_constraint(:project_id)
    |> foreign_key_constraint(:risk_id)
    |> foreign_key_constraint(:mitigation_id)
    |> foreign_key_constraint(:responsible_actor_id)
    |> foreign_key_constraint(:creator_id)
    |> check_constraint(:resource_owner, 
        name: :must_belong_to_project_risk_or_mitigation,
        message: "must belong to either a project, risk, or mitigation")
  end

  defp validate_inventory_fields(changeset) do
    case get_field(changeset, :type) do
      "inventory" ->
        changeset
        |> validate_required([:inventory_item_id, :quantity_needed])
        |> validate_number(:reorder_threshold, greater_than: 0)
        |> validate_inventory_allocation()
      _ -> changeset
    end
  end

  defp validate_inventory_allocation(changeset) do
    quantity_needed = get_field(changeset, :quantity_needed) || 0
    quantity_allocated = get_field(changeset, :quantity_allocated) || 0

    if quantity_allocated > quantity_needed do
      add_error(changeset, :quantity_allocated, "cannot exceed quantity needed")
    else
      changeset
    end
  end
end 