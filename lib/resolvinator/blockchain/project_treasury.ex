defmodule Resolvinator.Blockchain.ProjectTreasury do
  @moduledoc """
  Manages project treasury funds and allocations:
  1. Contributor rewards pool
  2. Development fund
  3. Liquidity provision
  4. Emergency reserve
  """
  
  use Ecto.Schema
  import Ecto.Changeset
  import Ecto.Query
  alias Resolvinator.Repo
  alias Resolvinator.Projects.Project
  alias Resolvinator.Blockchain.{ProjectToken, ContributorRewards}

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "project_treasuries" do
    field :total_balance, :decimal, default: Decimal.new(0)
    field :rewards_pool, :decimal, default: Decimal.new(0)
    field :dev_fund, :decimal, default: Decimal.new(0)
    field :liquidity_fund, :decimal, default: Decimal.new(0)
    field :emergency_reserve, :decimal, default: Decimal.new(0)
    
    # Allocation percentages (must sum to 100)
    field :rewards_allocation, :decimal, default: Decimal.new("40")  # 40%
    field :dev_allocation, :decimal, default: Decimal.new("30")     # 30%
    field :liquidity_allocation, :decimal, default: Decimal.new("20") # 20%
    field :reserve_allocation, :decimal, default: Decimal.new("10")  # 10%
    
    belongs_to :project, Project
    has_many :allocations, TreasuryAllocation
    
    timestamps()
  end

  @doc """
  Creates a new project treasury.
  """
  def create_treasury(project, attrs \\ %{}) do
    %__MODULE__{}
    |> changeset(attrs)
    |> put_assoc(:project, project)
    |> Repo.insert()
  end

  @doc """
  Adds funds to the treasury and allocates them according to percentages.
  """
  def add_funds(treasury, amount) do
    Repo.transaction(fn ->
      # Update total balance
      treasury = 
        treasury
        |> change(%{total_balance: Decimal.add(treasury.total_balance, amount)})
        |> Repo.update!()
      
      # Allocate funds
      allocate_funds(treasury, amount)
      
      treasury
    end)
  end

  @doc """
  Releases funds from a specific allocation.
  """
  def release_funds(treasury, allocation, amount) do
    cond do
      allocation == :rewards_pool ->
        release_from_pool(treasury, :rewards_pool, amount)
      
      allocation == :dev_fund ->
        release_from_pool(treasury, :dev_fund, amount)
      
      allocation == :liquidity_fund ->
        release_from_pool(treasury, :liquidity_fund, amount)
      
      allocation == :emergency_reserve ->
        release_from_pool(treasury, :emergency_reserve, amount)
      
      true ->
        {:error, :invalid_allocation}
    end
  end

  @doc """
  Updates treasury allocation percentages.
  Requires governance approval.
  """
  def update_allocations(treasury, %{
    rewards_allocation: rewards,
    dev_allocation: dev,
    liquidity_allocation: liquidity,
    reserve_allocation: reserve
  } = allocations) do
    total = Decimal.add(rewards, dev)
            |> Decimal.add(liquidity)
            |> Decimal.add(reserve)
    
    if Decimal.eq?(total, Decimal.new(100)) do
      treasury
      |> changeset(allocations)
      |> Repo.update()
    else
      {:error, :invalid_allocation_total}
    end
  end

  @doc """
  Gets treasury metrics and allocation info.
  """
  def get_metrics(treasury) do
    %{
      total_balance: treasury.total_balance,
      allocations: %{
        rewards_pool: %{
          balance: treasury.rewards_pool,
          allocation: treasury.rewards_allocation
        },
        dev_fund: %{
          balance: treasury.dev_fund,
          allocation: treasury.dev_allocation
        },
        liquidity_fund: %{
          balance: treasury.liquidity_fund,
          allocation: treasury.liquidity_allocation
        },
        emergency_reserve: %{
          balance: treasury.emergency_reserve,
          allocation: treasury.reserve_allocation
        }
      },
      recent_transactions: get_recent_transactions(treasury.id)
    }
  end

  # Private functions

  defp allocate_funds(treasury, amount) do
    # Calculate amounts for each pool
    rewards_amount = calculate_allocation(amount, treasury.rewards_allocation)
    dev_amount = calculate_allocation(amount, treasury.dev_allocation)
    liquidity_amount = calculate_allocation(amount, treasury.liquidity_allocation)
    reserve_amount = calculate_allocation(amount, treasury.reserve_allocation)
    
    # Update pool balances
    treasury
    |> change(%{
      rewards_pool: Decimal.add(treasury.rewards_pool, rewards_amount),
      dev_fund: Decimal.add(treasury.dev_fund, dev_amount),
      liquidity_fund: Decimal.add(treasury.liquidity_fund, liquidity_amount),
      emergency_reserve: Decimal.add(treasury.emergency_reserve, reserve_amount)
    })
    |> Repo.update!()
    
    # Record allocations
    record_allocation(treasury, :rewards_pool, rewards_amount)
    record_allocation(treasury, :dev_fund, dev_amount)
    record_allocation(treasury, :liquidity_fund, liquidity_amount)
    record_allocation(treasury, :emergency_reserve, reserve_amount)
  end

  defp calculate_allocation(amount, percentage) do
    Decimal.mult(amount, Decimal.div(percentage, Decimal.new(100)))
  end

  defp release_from_pool(treasury, pool, amount) do
    current_balance = Map.get(treasury, pool)
    
    if Decimal.compare(current_balance, amount) == :gt do
      {field_to_update, new_balance} = {pool, Decimal.sub(current_balance, amount)}
      
      Repo.transaction(fn ->
        # Update pool balance
        treasury = 
          treasury
          |> change(%{field_to_update => new_balance})
          |> Repo.update!()
        
        # Record transaction
        record_transaction(treasury, pool, :release, amount)
        
        {:ok, treasury}
      end)
    else
      {:error, :insufficient_funds}
    end
  end

  defp record_allocation(treasury, pool, amount) do
    %TreasuryAllocation{}
    |> TreasuryAllocation.changeset(%{
      pool: Atom.to_string(pool),
      amount: amount,
      transaction_type: "allocation"
    })
    |> put_assoc(:treasury, treasury)
    |> Repo.insert()
  end

  defp record_transaction(treasury, pool, type, amount) do
    %TreasuryTransaction{}
    |> TreasuryTransaction.changeset(%{
      pool: Atom.to_string(pool),
      amount: amount,
      transaction_type: Atom.to_string(type)
    })
    |> put_assoc(:treasury, treasury)
    |> Repo.insert()
  end

  defp get_recent_transactions(treasury_id) do
    from(t in TreasuryTransaction,
      where: t.treasury_id == ^treasury_id,
      order_by: [desc: t.inserted_at],
      limit: 10
    )
    |> Repo.all()
  end

  defp changeset(treasury, attrs) do
    treasury
    |> cast(attrs, [:rewards_allocation, :dev_allocation, 
                   :liquidity_allocation, :reserve_allocation])
    |> validate_required([:rewards_allocation, :dev_allocation,
                         :liquidity_allocation, :reserve_allocation])
    |> validate_number(:rewards_allocation, greater_than_or_equal_to: 0)
    |> validate_number(:dev_allocation, greater_than_or_equal_to: 0)
    |> validate_number(:liquidity_allocation, greater_than_or_equal_to: 0)
    |> validate_number(:reserve_allocation, greater_than_or_equal_to: 0)
    |> validate_allocations_total()
  end

  defp validate_allocations_total(changeset) do
    rewards = get_field(changeset, :rewards_allocation)
    dev = get_field(changeset, :dev_allocation)
    liquidity = get_field(changeset, :liquidity_allocation)
    reserve = get_field(changeset, :reserve_allocation)
    
    total = Decimal.add(rewards, dev)
            |> Decimal.add(liquidity)
            |> Decimal.add(reserve)
    
    if Decimal.eq?(total, Decimal.new(100)) do
      changeset
    else
      add_error(changeset, :allocations, "must sum to 100%")
    end
  end
end
