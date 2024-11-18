defmodule Resolvinator.Blockchain.ProjectDAO do
  @moduledoc """
  Implements MakerDAO-like functionality for project governance.
  
  Key components:
  - Project Collateral Positions (PCPs) - Similar to CDPs
  - Dual token system: 
    * RSLV (like DAI) - Stable governance token
    * RPT (like MKR) - Project governance token
  - Stability mechanisms
  - Governance voting
  """
  
  use Ecto.Schema
  import Ecto.Changeset
  import Ecto.Query
  alias Resolvinator.Repo
  alias Resolvinator.Projects.Project
  alias Resolvinator.Accounts.User
  alias Resolvinator.Blockchain.ProjectToken

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "project_daos" do
    field :collateral_ratio, :decimal, default: Decimal.new("1.5")  # 150% collateralization
    field :stability_fee, :decimal, default: Decimal.new("0.01")    # 1% annual fee
    field :debt_ceiling, :decimal                                   # Max RSLV that can be generated
    field :total_debt, :decimal, default: Decimal.new(0)           # Current RSLV in circulation
    field :liquidation_ratio, :decimal, default: Decimal.new("1.1") # 110% liquidation threshold
    field :governance_delay, :integer, default: 24 * 60 * 60        # 24 hours in seconds
    
    belongs_to :project, Project
    has_many :collateral_positions, ProjectCollateralPosition
    has_many :governance_proposals, GovernanceProposal
    
    timestamps()
  end

  @doc """
  Creates a new Project DAO with initial settings.
  """
  def create_dao(project, attrs \\ %{}) do
    %__MODULE__{}
    |> changeset(attrs)
    |> put_assoc(:project, project)
    |> Repo.insert()
  end

  @doc """
  Opens a new Project Collateral Position (PCP).
  Similar to MakerDAO's CDP but using project tokens as collateral.
  """
  def open_position(dao, user, collateral_amount, rslv_to_generate) do
    # Calculate if the position would be properly collateralized
    min_collateral = calculate_min_collateral(rslv_to_generate, dao.collateral_ratio)
    
    if Decimal.compare(collateral_amount, min_collateral) == :gt do
      %ProjectCollateralPosition{}
      |> ProjectCollateralPosition.changeset(%{
        collateral_amount: collateral_amount,
        debt_amount: rslv_to_generate,
        liquidation_price: calculate_liquidation_price(
          collateral_amount,
          rslv_to_generate,
          dao.liquidation_ratio
        )
      })
      |> put_assoc(:dao, dao)
      |> put_assoc(:owner, user)
      |> Repo.insert()
    else
      {:error, :insufficient_collateral}
    end
  end

  @doc """
  Submits a governance proposal.
  Similar to MakerDAO's governance polls.
  """
  def submit_proposal(dao, user, %{title: _, description: _, changes: _} = proposal_data) do
    voting_power = ProjectToken.get_voting_power(user.id, dao.project_id)
    
    if Decimal.compare(voting_power, Decimal.new(0)) == :gt do
      %GovernanceProposal{}
      |> GovernanceProposal.changeset(Map.put(proposal_data, :end_time, 
        DateTime.add(DateTime.utc_now(), dao.governance_delay)))
      |> put_assoc(:dao, dao)
      |> put_assoc(:proposer, user)
      |> Repo.insert()
    else
      {:error, :insufficient_voting_power}
    end
  end

  @doc """
  Casts a vote on a governance proposal.
  """
  def cast_vote(proposal, user, support) do
    voting_power = ProjectToken.get_voting_power(user.id, proposal.dao.project_id)
    
    if Decimal.compare(voting_power, Decimal.new(0)) == :gt do
      %Vote{}
      |> Vote.changeset(%{
        support: support,
        voting_power: voting_power
      })
      |> put_assoc(:proposal, proposal)
      |> put_assoc(:voter, user)
      |> Repo.insert()
    else
      {:error, :insufficient_voting_power}
    end
  end

  @doc """
  Checks positions for liquidation.
  Similar to MakerDAO's liquidation mechanism.
  """
  def check_liquidations(dao) do
    from(p in ProjectCollateralPosition,
      where: p.dao_id == ^dao.id and
             p.liquidation_price >= fragment("current_price"))
    |> Repo.all()
    |> Enum.each(&liquidate_position/1)
  end

  @doc """
  Calculates stability fees for all positions.
  Similar to MakerDAO's stability fee accrual.
  """
  def accrue_stability_fees(dao) do
    dao.collateral_positions
    |> Enum.each(fn position ->
      time_elapsed = DateTime.diff(DateTime.utc_now(), position.updated_at)
      fee = calculate_stability_fee(position.debt_amount, dao.stability_fee, time_elapsed)
      
      position
      |> ProjectCollateralPosition.changeset(%{
        debt_amount: Decimal.add(position.debt_amount, fee)
      })
      |> Repo.update()
    end)
  end

  defp calculate_min_collateral(rslv_amount, collateral_ratio) do
    Decimal.mult(rslv_amount, collateral_ratio)
  end

  defp calculate_liquidation_price(collateral_amount, debt_amount, liquidation_ratio) do
    Decimal.div(
      Decimal.mult(debt_amount, liquidation_ratio),
      collateral_amount
    )
  end

  defp calculate_stability_fee(debt_amount, annual_rate, seconds) do
    # Convert annual rate to per-second rate
    per_second_rate = Decimal.div(annual_rate, Decimal.new(365 * 24 * 60 * 60))
    
    Decimal.mult(
      debt_amount,
      Decimal.mult(per_second_rate, Decimal.new(seconds))
    )
  end

  defp liquidate_position(position) do
    # In a real implementation, this would:
    # 1. Auction the collateral
    # 2. Pay off the debt
    # 3. Return remaining collateral to owner
    # 4. Apply penalties
    position
    |> ProjectCollateralPosition.changeset(%{status: "liquidated"})
    |> Repo.update()
  end

  defp changeset(dao, attrs) do
    dao
    |> cast(attrs, [:collateral_ratio, :stability_fee, :debt_ceiling, 
                   :total_debt, :liquidation_ratio, :governance_delay])
    |> validate_required([:collateral_ratio, :stability_fee, :liquidation_ratio])
    |> validate_number(:collateral_ratio, greater_than: 1)
    |> validate_number(:stability_fee, greater_than_or_equal_to: 0)
    |> validate_number(:liquidation_ratio, greater_than: 1)
  end
end
