defmodule ResolvinatorWeb.API.RewardController do
  use ResolvinatorWeb, :controller
  import ResolvinatorWeb.API.JSONHelpers

  alias Resolvinator.Rewards

  def index(conn, params) do
    page = params["page"] || %{"number" => 1, "size" => 20}
    includes = params["include"]
    filters = Map.get(params, "filter", %{})

    {rewards, page_info} = Rewards.list_rewards(
      page: page,
      includes: includes,
      filters: filters
    )

    conn
    |> put_status(:ok)
    |> json(paginate(
      Enum.map(rewards, &RewardJSON.data(&1, includes: includes)),
      page_info
    ))
  end

  def create(conn, %{"reward" => reward_params}) do
    create_params = Map.put(reward_params, "creator_id", conn.assigns.current_user.id)

    case Rewards.create_reward(create_params) do
      {:ok, reward} ->
        conn
        |> put_status(:created)
        |> json(%{data: RewardJSON.data(reward)})

      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> json(%{errors: ChangesetErrors.format_errors(changeset)})
    end
  end

  def claim(conn, %{"id" => id, "evidence" => evidence}) do
    case Rewards.claim_reward(id, conn.assigns.current_user.id, evidence) do
      {:ok, claim} ->
        conn
        |> put_status(:created)
        |> json(%{data: RewardJSON.claim_data(claim)})

      {:error, :prerequisites_not_met} ->
        conn
        |> put_status(:unprocessable_entity)
        |> json(%{error: "Prerequisites not met for this reward"})

      {:error, :already_claimed} ->
        conn
        |> put_status(:conflict)
        |> json(%{error: "Reward already claimed"})

      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> json(%{errors: ChangesetErrors.format_errors(changeset)})
    end
  end

  def approve_claim(conn, %{"claim_id" => claim_id}) do
    case Rewards.approve_claim(claim_id, conn.assigns.current_user.id) do
      {:ok, claim} ->
        json(conn, %{data: RewardJSON.claim_data(claim)})

      {:error, :not_found} ->
        conn
        |> put_status(:not_found)
        |> json(%{error: "Claim not found"})

      {:error, :unauthorized} ->
        conn
        |> put_status(:forbidden)
        |> json(%{error: "Not authorized to approve claims"})
    end
  end

  def get_prerequisites(conn, %{"id" => id}) do
    case Rewards.get_reward_prerequisites(id) do
      {:ok, prerequisites} ->
        json(conn, %{data: prerequisites})

      {:error, :not_found} ->
        conn
        |> put_status(:not_found)
        |> json(%{error: "Reward not found"})
    end
  end

  def check_eligibility(conn, %{"id" => id}) do
    case Rewards.check_eligibility(id, conn.assigns.current_user.id) do
      {:ok, eligibility} ->
        json(conn, %{data: eligibility})

      {:error, :not_found} ->
        conn
        |> put_status(:not_found)
        |> json(%{error: "Reward not found"})
    end
  end

  def show(conn, %{"id" => id}) do
    case Rewards.get_reward(id) do
      {:ok, reward} ->
        conn
        |> put_status(:ok)
        |> json(%{data: RewardJSON.data(reward)})

      {:error, :not_found} ->
        conn
        |> put_status(:not_found)
        |> json(%{error: "Reward not found"})
    end
  end

  def update(conn, %{"id" => id, "reward" => reward_params}) do
    with {:ok, reward} <- Rewards.get_reward(id),
         {:ok, updated_reward} <- Rewards.update_reward(reward, reward_params) do
      json(conn, %{data: RewardJSON.data(updated_reward)})
    else
      {:error, :not_found} ->
        conn
        |> put_status(:not_found)
        |> json(%{error: "Reward not found"})

      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> json(%{errors: ChangesetErrors.format_errors(changeset)})
    end
  end

  def delete(conn, %{"id" => id}) do
    with {:ok, reward} <- Rewards.get_reward(id),
         {:ok, _} <- Rewards.delete_reward(reward) do
      send_resp(conn, :no_content, "")
    else
      {:error, :not_found} ->
        conn
        |> put_status(:not_found)
        |> json(%{error: "Reward not found"})

      {:error, _} ->
        conn
        |> put_status(:unprocessable_entity)
        |> json(%{error: "Could not delete reward"})
    end
  end
end
