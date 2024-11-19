defmodule Resolvinator.Blockchain.PriceOracle do
  @moduledoc """
  Price oracle for project tokens. Determines token values based on:
  1. Project metrics (stars, forks, activity)
  2. Market activity (trades, liquidity)
  3. Contributor activity
  4. Token economics (supply, staking)
  """
  
  use GenServer
  import Ecto.Query
  alias Resolvinator.Repo
  alias Resolvinator.Projects.Project
  alias Resolvinator.Blockchain.{ProjectToken, ContributorRewards}
  import Ecto.Schema

  # Import Ecto.Schema types
  @type binary_id :: Ecto.UUID.t()

  # Update prices every 5 minutes
  @price_update_interval 5 * 60 * 1000

  # State structure
  @type t :: %{
    prices: %{binary_id() => Decimal.t()},  # project_id => price
    last_update: DateTime.t(),
    metrics: %{binary_id() => map()}        # project_id => metrics
  }

  def start_link(_opts) do
    GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
  end

  @impl true
  def init(state) do
    schedule_price_update()
    {:ok, %{prices: %{}, last_update: DateTime.utc_now(), metrics: %{}}}
  end

  @impl true
  def handle_info(:update_prices, state) do
    new_prices = calculate_all_prices()
    new_metrics = gather_all_metrics()
    
    schedule_price_update()
    
    {:noreply, %{state |
      prices: new_prices,
      last_update: DateTime.utc_now(),
      metrics: new_metrics
    }}
  end

  @impl true
  def handle_call({:get_price, project_id}, _from, state) do
    price = Map.get(state.prices, project_id, Decimal.new(0))
    {:reply, price, state}
  end

  def handle_call({:get_metrics, project_id}, _from, state) do
    metrics = Map.get(state.metrics, project_id, %{})
    {:reply, metrics, state}
  end

  # Client API

  @doc """
  Gets the current price for a project's token.
  """
  def get_price(project_id) do
    GenServer.call(__MODULE__, {:get_price, project_id})
  end

  @doc """
  Gets the current metrics for a project.
  """
  def get_metrics(project_id) do
    GenServer.call(__MODULE__, {:get_metrics, project_id})
  end

  # Private functions

  defp schedule_price_update do
    Process.send_after(self(), :update_prices, @price_update_interval)
  end

  defp calculate_all_prices do
    Project.list_projects()
    |> Enum.map(&calculate_project_price/1)
    |> Enum.into(%{})
  end

  defp calculate_project_price(project) do
    # Base price factors
    token_supply = get_token_supply(project.id)
    total_staked = get_total_staked(project.id)
    contributor_count = get_contributor_count(project.id)
    activity_score = calculate_activity_score(project)
    
    # Market factors
    liquidity = get_liquidity(project.id)
    trade_volume = get_trade_volume(project.id)
    
    # Calculate weighted price
    price = calculate_weighted_price(%{
      token_supply: token_supply,
      total_staked: total_staked,
      contributor_count: contributor_count,
      activity_score: activity_score,
      liquidity: liquidity,
      trade_volume: trade_volume
    })

    {project.id, price}
  end

  defp gather_all_metrics do
    Project.list_projects()
    |> Enum.map(&gather_project_metrics/1)
    |> Enum.into(%{})
  end

  defp gather_project_metrics(project) do
    metrics = %{
      token_supply: get_token_supply(project.id),
      total_staked: get_total_staked(project.id),
      contributor_count: get_contributor_count(project.id),
      activity_score: calculate_activity_score(project),
      liquidity: get_liquidity(project.id),
      trade_volume: get_trade_volume(project.id),
      contributor_activity: get_contributor_activity(project.id),
      governance_activity: get_governance_activity(project.id)
    }

    {project.id, metrics}
  end

  defp get_token_supply(project_id) do
    ProjectToken.get_total_supply(project_id)
  end

  defp get_total_staked(project_id) do
    ProjectToken.get_total_staked(project_id)
  end

  defp get_contributor_count(project_id) do
    ContributorRewards.get_project_contributors(project_id)
    |> length()
  end

  defp calculate_activity_score(project) do
    # Factors:
    # 1. Recent commits
    # 2. Open PRs
    # 3. Issue activity
    # 4. Documentation updates
    Decimal.new("1.0")  # Placeholder
  end

  defp get_liquidity(project_id) do
    # Get total liquidity from AMM pools
    Decimal.new("0")  # Placeholder
  end

  defp get_trade_volume(project_id) do
    # Get 24h trading volume
    Decimal.new("0")  # Placeholder
  end

  defp get_contributor_activity(project_id) do
    # Recent contributor actions
    ContributorRewards.get_recent_activity(project_id)
  end

  defp get_governance_activity(project_id) do
    # Recent governance actions
    # Proposals, votes, etc.
    0  # Placeholder
  end

  defp calculate_weighted_price(metrics) do
    # Weight factors
    weights = %{
      token_supply: Decimal.new("0.2"),
      total_staked: Decimal.new("0.3"),
      contributor_count: Decimal.new("0.15"),
      activity_score: Decimal.new("0.15"),
      liquidity: Decimal.new("0.1"),
      trade_volume: Decimal.new("0.1")
    }

    # Calculate weighted sum
    Enum.reduce(weights, Decimal.new(0), fn {factor, weight}, acc ->
      factor_value = Map.get(metrics, factor, Decimal.new(0))
      weighted_value = Decimal.mult(factor_value, weight)
      Decimal.add(acc, weighted_value)
    end)
  end
end
