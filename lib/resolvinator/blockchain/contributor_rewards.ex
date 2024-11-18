defmodule Resolvinator.Blockchain.ContributorRewards do
  @moduledoc """
  Handles contributor reward distribution based on:
  1. Code contributions (commits, PRs)
  2. Issue resolution
  3. Documentation
  4. Community support
  5. Project governance participation
  """
  
  use Ecto.Schema
  import Ecto.Changeset
  import Ecto.Query
  alias Resolvinator.Repo
  alias Resolvinator.Accounts.User
  alias Resolvinator.Projects.Project
  alias Resolvinator.Blockchain.ProjectToken

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "contributor_rewards" do
    field :contribution_type, :string  # code, issue, docs, support, governance
    field :weight, :decimal           # Importance multiplier
    field :tokens_earned, :decimal    # RPT tokens earned
    field :description, :string       # What was contributed
    field :proof_of_work, :string    # Link to PR, issue, doc, etc.
    field :status, :string           # pending, approved, rejected, distributed
    
    belongs_to :project, Project
    belongs_to :contributor, User
    belongs_to :approver, User
    
    timestamps()
  end

  @contribution_weights %{
    "code" => Decimal.new("1.0"),      # Base weight for code contributions
    "issue" => Decimal.new("0.5"),     # Issue resolution
    "docs" => Decimal.new("0.3"),      # Documentation
    "support" => Decimal.new("0.2"),   # Community support
    "governance" => Decimal.new("0.4")  # Governance participation
  }

  @doc """
  Records a new contribution and calculates reward.
  """
  def record_contribution(project, contributor, attrs) do
    # Calculate base reward based on contribution type
    base_reward = calculate_base_reward(project, attrs["contribution_type"])
    
    # Apply multipliers based on:
    # 1. Project importance (stars, forks, activity)
    # 2. Contribution complexity
    # 3. Contributor reputation
    weighted_reward = apply_multipliers(base_reward, project, contributor)
    
    %__MODULE__{}
    |> changeset(Map.put(attrs, "tokens_earned", weighted_reward))
    |> put_assoc(:project, project)
    |> put_assoc(:contributor, contributor)
    |> Repo.insert()
  end

  @doc """
  Approves a contribution and triggers reward distribution.
  """
  def approve_contribution(reward, approver) do
    with {:ok, reward} <- 
           Repo.transaction(fn ->
             # 1. Update reward status
             reward = 
               reward
               |> changeset(%{status: "approved"})
               |> put_assoc(:approver, approver)
               |> Repo.update!()

             # 2. Mint reward tokens
             {:ok, _token} = ProjectToken.mint_governance_tokens(
               reward.project,
               reward.contributor,
               reward.tokens_earned
             )

             # 3. Update contributor reputation
             update_contributor_reputation(reward)

             reward
           end) do
      {:ok, reward}
    end
  end

  @doc """
  Distributes pending rewards for a project.
  """
  def distribute_rewards(project) do
    from(r in __MODULE__,
      where: r.project_id == ^project.id and r.status == "approved"
    )
    |> Repo.all()
    |> Enum.each(fn reward ->
      # 1. Transfer tokens to contributor
      {:ok, _token} = ProjectToken.transfer_to(
        reward.project,
        reward.contributor,
        reward.tokens_earned
      )

      # 2. Mark as distributed
      reward
      |> changeset(%{status: "distributed"})
      |> Repo.update()
    end)
  end

  @doc """
  Gets total rewards for a contributor across all projects.
  """
  def get_contributor_rewards(contributor_id) do
    from(r in __MODULE__,
      where: r.contributor_id == ^contributor_id and r.status == "distributed",
      group_by: [r.project_id, r.contribution_type],
      select: {r.project_id, r.contribution_type, sum(r.tokens_earned)}
    )
    |> Repo.all()
  end

  @doc """
  Gets project contributors ranked by rewards earned.
  """
  def get_project_contributors(project_id) do
    from(r in __MODULE__,
      where: r.project_id == ^project_id and r.status == "distributed",
      group_by: r.contributor_id,
      select: {r.contributor_id, sum(r.tokens_earned)},
      order_by: [desc: sum(r.tokens_earned)]
    )
    |> Repo.all()
  end

  # Private functions

  defp calculate_base_reward(project, contribution_type) do
    base_amount = Decimal.new("100")  # Base 100 tokens per contribution
    weight = Map.get(@contribution_weights, contribution_type, Decimal.new("0.1"))
    
    Decimal.mult(base_amount, weight)
  end

  defp apply_multipliers(base_reward, project, contributor) do
    project_multiplier = calculate_project_multiplier(project)
    reputation_multiplier = calculate_reputation_multiplier(contributor)
    
    base_reward
    |> Decimal.mult(project_multiplier)
    |> Decimal.mult(reputation_multiplier)
    |> Decimal.round(2)
  end

  defp calculate_project_multiplier(project) do
    # Factor in:
    # 1. Project stars/forks
    # 2. Active contributors
    # 3. Recent activity
    # For now, return a simple multiplier
    Decimal.new("1.0")
  end

  defp calculate_reputation_multiplier(contributor) do
    # Factor in:
    # 1. Past contributions
    # 2. Contribution quality
    # 3. Community standing
    # For now, return a simple multiplier
    Decimal.new("1.0")
  end

  defp update_contributor_reputation(reward) do
    # Update contributor's reputation based on:
    # 1. Contribution type
    # 2. Reward size
    # 3. Project importance
    # To be implemented
    :ok
  end

  defp changeset(reward, attrs) do
    reward
    |> cast(attrs, [:contribution_type, :weight, :tokens_earned, 
                   :description, :proof_of_work, :status])
    |> validate_required([:contribution_type, :description, :proof_of_work])
    |> validate_inclusion(:contribution_type, Map.keys(@contribution_weights))
    |> validate_inclusion(:status, ~w(pending approved rejected distributed))
  end
end
