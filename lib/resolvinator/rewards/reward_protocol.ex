
defprotocol Resolvinator.Rewards.RewardProtocol do
  @doc """
  Converts a reward to a map representation.
  """
  def to_map(reward)

  @doc """
  Gets the core attributes of a reward.
  """
  def get_attributes(reward)

  @doc """
  Gets the formatted value of a reward.
  """
  def get_formatted_value(reward)

  @doc """
  Gets the USD equivalent value of a reward.
  """
  def get_usd_value(reward)
end

defimpl Resolvinator.Rewards.RewardProtocol, for: Resolvinator.Rewards.Reward do
  alias Resolvinator.Rewards.CryptoReward

  def to_map(reward) do
    base_map = %{
      "id" => reward.id,
      "name" => reward.name,
      "description" => reward.description,
      "value" => reward.value,
      "currency" => reward.currency,
      "status" => Atom.to_string(reward.status),
      "reward_type" => Atom.to_string(reward.reward_type),
      "tier" => reward.tier && Atom.to_string(reward.tier),
      "achievement_date" => reward.achievement_date,
      "expiry_date" => reward.expiry_date,
      "criteria" => reward.criteria,
      "metadata" => reward.metadata
    }

    case reward.reward_type do
      :crypto ->
        Map.merge(base_map, %{
          "blockchain" => reward.blockchain && Atom.to_string(reward.blockchain),
          "wallet_address" => reward.wallet_address,
          "transaction_hash" => reward.transaction_hash,
          "token_contract" => reward.token_contract,
          "token_id" => reward.token_id,
          "token_standard" => reward.token_standard && Atom.to_string(reward.token_standard)
        })
      :risk ->
        Map.merge(base_map, %{
          "probability" => reward.probability && Atom.to_string(reward.probability),
          "timeline" => reward.timeline && Atom.to_string(reward.timeline),
          "dependencies" => reward.dependencies
        })
      _ ->
        base_map
    end
  end

  def get_attributes(reward) do
    base_attrs = %{
      id: reward.id,
      name: reward.name,
      description: reward.description,
      value: reward.value,
      currency: reward.currency,
      status: reward.status
    }

    case reward.reward_type do
      :crypto ->
        Map.merge(base_attrs, %{
          blockchain: reward.blockchain,
          wallet_address: reward.wallet_address,
          token_standard: reward.token_standard
        })
      _ ->
        base_attrs
    end
  end

  def get_formatted_value(reward) do
    case reward.reward_type do
      :crypto -> CryptoReward.format_value(reward.value, reward.currency)
      _ -> "$#{reward.value}"
    end
  end

  def get_usd_value(reward) do
    case reward.reward_type do
      :crypto -> CryptoReward.get_usd_value(reward.value, reward.currency)
      _ -> {:ok, reward.value}
    end
  end
end
