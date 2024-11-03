defmodule Resolvinator.Rewards do
  import Ecto.Query
  alias Resolvinator.Repo
  alias Resolvinator.Rewards.{Reward, RewardClaim, RewardPrerequisite}

  def list_rewards(opts \\ []) do
    Reward
    |> filter_by_project(opts[:project_id])
    |> filter_by_status(opts[:status])
    |> filter_by_type(opts[:reward_type])
    |> Repo.all()
  end

  def get_reward(id) do
    case Repo.get(Reward, id) do
      nil -> {:error, :not_found}
      reward -> {:ok, reward}
    end
  end

  def create_reward(attrs) do
    %Reward{}
    |> Reward.changeset(attrs)
    |> Repo.insert()
  end

  def claim_reward(reward_id, user_id, evidence) do
    with {:ok, reward} <- get_reward(reward_id),
         :ok <- validate_prerequisites(reward, user_id),
         :ok <- validate_criteria(reward, evidence) do
      %RewardClaim{}
      |> RewardClaim.changeset(%{
        reward_id: reward_id,
        user_id: user_id,
        evidence: evidence,
        status: :pending
      })
      |> Repo.insert()
    end
  end

  def approve_claim(claim_id, reviewer_id) do
    Repo.transaction(fn ->
      claim = Repo.get!(RewardClaim, claim_id)

      claim
      |> RewardClaim.changeset(%{
        status: :approved,
        reviewed_at: DateTime.utc_now(),
        reviewed_by_id: reviewer_id
      })
      |> Repo.update!()

      claim.reward
      |> Reward.changeset(%{
        status: :achieved,
        achievement_date: DateTime.utc_now(),
        achiever_id: claim.user_id
      })
      |> Repo.update!()
    end)
  end

  def get_reward_prerequisites(reward_id) do
    case get_reward(reward_id) do
      {:ok, reward} ->
        prerequisites =
          RewardPrerequisite
          |> where([p], p.reward_id == ^reward_id)
          |> preload(:required_reward)
          |> Repo.all()
        {:ok, prerequisites}
      error -> error
    end
  end

  def check_eligibility(reward_id, user_id) do
    with {:ok, reward} <- get_reward(reward_id),
         :ok <- validate_prerequisites(reward, user_id) do
      {:ok, %{eligible: true, reason: "All prerequisites met"}}
    else
      {:error, reason} -> {:ok, %{eligible: false, reason: reason}}
    end
  end

  # Risk Reward specific functions
  def create_risk_reward(attrs) do
    %Reward{}
    |> Reward.risk_reward_changeset(attrs)
    |> Repo.insert()
  end

  def update_risk_reward(reward, attrs) do
    reward
    |> Reward.risk_reward_changeset(attrs)
    |> Repo.update()
  end

  def get_rewards_by_dependencies(dependency_ids) when is_list(dependency_ids) do
    Reward
    |> where([r], fragment("? && ?", r.dependencies, ^dependency_ids))
    |> Repo.all()
  end

  def get_risk_rewards_for_project(project_id) do
    Reward
    |> where([r], r.project_id == ^project_id)
    |> where([r], r.reward_type == :risk)
    |> Repo.all()
  end

  def get_risk_rewards_by_probability(probability) do
    Reward
    |> where([r], r.reward_type == :risk)
    |> where([r], r.probability == ^probability)
    |> Repo.all()
  end

  # Private helper functions
  defp validate_prerequisites(reward, user_id) do
    # Query to check if user has all required prerequisites
    prerequisites_query = from p in RewardPrerequisite,
      where: p.reward_id == ^reward.id,
      join: r in Reward, on: r.id == p.required_reward_id,
      where: r.achiever_id == ^user_id and r.status == :achieved,
      select: count(p.id)

    case Repo.one(prerequisites_query) do
      count when count >= reward.required_prerequisites_count -> :ok
      _ -> {:error, "Not all prerequisites have been met"}
    end
  end

  defp validate_criteria(_reward, _evidence) do
    # Implement criteria validation logic
    :ok
  end

  defp filter_by_project(query, nil), do: query
  defp filter_by_project(query, project_id) do
    where(query, [r], r.project_id == ^project_id)
  end

  defp filter_by_status(query, nil), do: query
  defp filter_by_status(query, status) do
    where(query, [r], r.status == ^status)
  end

  defp filter_by_type(query, nil), do: query
  defp filter_by_type(query, type) do
    where(query, [r], r.reward_type == ^type)
  end
end
