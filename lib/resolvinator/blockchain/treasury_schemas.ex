defmodule Resolvinator.Blockchain.TreasuryAllocation do
  @moduledoc """
  Schema for treasury fund allocations.
  """
  
  use Ecto.Schema
  import Ecto.Changeset
  alias Resolvinator.Blockchain.ProjectTreasury

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "treasury_allocations" do
    field :pool, :string
    field :amount, :decimal
    field :transaction_type, :string  # allocation, release
    
    belongs_to :treasury, ProjectTreasury
    
    timestamps()
  end

  def changeset(allocation, attrs) do
    allocation
    |> cast(attrs, [:pool, :amount, :transaction_type])
    |> validate_required([:pool, :amount, :transaction_type])
    |> validate_inclusion(:pool, ~w(rewards_pool dev_fund liquidity_fund emergency_reserve))
    |> validate_inclusion(:transaction_type, ~w(allocation release))
    |> validate_number(:amount, greater_than: 0)
  end
end

defmodule Resolvinator.Blockchain.TreasuryTransaction do
  @moduledoc """
  Schema for treasury transactions.
  """
  
  use Ecto.Schema
  import Ecto.Changeset
  alias Resolvinator.Blockchain.ProjectTreasury

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "treasury_transactions" do
    field :pool, :string
    field :amount, :decimal
    field :transaction_type, :string  # allocation, release, transfer
    field :description, :string
    
    belongs_to :treasury, ProjectTreasury
    
    timestamps()
  end

  def changeset(transaction, attrs) do
    transaction
    |> cast(attrs, [:pool, :amount, :transaction_type, :description])
    |> validate_required([:pool, :amount, :transaction_type])
    |> validate_inclusion(:pool, ~w(rewards_pool dev_fund liquidity_fund emergency_reserve))
    |> validate_inclusion(:transaction_type, ~w(allocation release transfer))
    |> validate_number(:amount, greater_than: 0)
  end
end
