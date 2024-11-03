defmodule ResolvinatorWeb.API.RewardJSON do
  import ResolvinatorWeb.API.JSONHelpers
  alias ResolvinatorWeb.API.{ProjectJSON, UserJSON, RiskJSON, MitigationJSON}

  def index(%{rewards: rewards, page_info: page_info}) do
    %{
      data: for(reward <- rewards, do: data(reward)),
      page_info: page_info
    }
  end

  def show(%{reward: reward}) do
    %{data: data(reward)}
  end

  def data(reward, opts \\ []) do
    includes = Keyword.get(opts, :includes, [])

    base = %{
      id: reward.id,
      type: "reward",
      attributes: %{
        name: reward.name,
        description: reward.description,
        value: reward.value,
        status: reward.status,
        reward_type: reward.reward_type,
        tier: reward.tier,
        achievement_date: reward.achievement_date,
        expiry_date: reward.expiry_date,
        criteria: reward.criteria,
        probability: reward.probability,
        timeline: reward.timeline,
        dependencies: reward.dependencies,
        metadata: reward.metadata,
        inserted_at: reward.inserted_at,
        updated_at: reward.updated_at
      },
      relationships: %{}
    }

    relationships = %{}
    |> maybe_add_relationship("project", reward.project, &ProjectJSON.reference_data/1, includes)
    |> maybe_add_relationship("achiever", reward.achiever, &UserJSON.reference_data/1, includes)
    |> maybe_add_relationship("creator", reward.creator, &UserJSON.reference_data/1, includes)
    |> maybe_add_relationship("risk", reward.risk, &RiskJSON.reference_data/1, includes)
    |> maybe_add_relationship("mitigation", reward.mitigation, &MitigationJSON.reference_data/1, includes)
    |> maybe_add_relationship("prerequisites", reward.prerequisites, &prerequisite_data/1, includes)
    |> maybe_add_relationship("claims", reward.claims, &claim_data/1, includes)
    |> maybe_add_relationship("risk", reward.risk, &ResolvinatorWeb.API.RiskJSON.reference_data/1, includes)
    |> maybe_add_relationship("mitigation", reward.mitigation, &ResolvinatorWeb.API.MitigationJSON.reference_data/1, includes)
    |> maybe_add_relationship("inventory_item", reward.inventory_item, &ResolvinatorWeb.API.InventoryJSON.reference_data/1, includes)

    Map.put(base, :relationships, relationships)
  end

  def reference_data(reward) do
    %{
      id: reward.id,
      type: "reward",
      attributes: %{
        name: reward.name,
        value: reward.value,
        status: reward.status,
        reward_type: reward.reward_type,
        tier: reward.tier
      }
    }
  end

  def claim_data(claim, _opts \\ []) do
    %{
      id: claim.id,
      type: "reward_claim",
      attributes: %{
        status: claim.status,
        evidence: claim.evidence,
        reviewed_at: claim.reviewed_at,
        inserted_at: claim.inserted_at,
        updated_at: claim.updated_at
      },
      relationships: %{
        user: ResolvinatorWeb.API.UserJSON.reference_data(claim.user),
        reviewer: claim.reviewed_by_id && ResolvinatorWeb.API.UserJSON.reference_data(claim.reviewer)
      }
    }
  end

  defp prerequisite_data(prerequisite, _opts \\ []) do
    %{
      id: prerequisite.id,
      type: "reward_prerequisite",
      attributes: %{
        required_count: prerequisite.required_count
      },
      relationships: %{
        required_reward: reference_data(prerequisite.required_reward)
      }
    }
  end
end
