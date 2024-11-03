defprotocol Resolvinator.Rewards.RewardProtocol do
  @doc "Convert reward to dictionary format"
  def to_map(reward)

  @doc "Get the reward's basic attributes"
  def get_attributes(reward)
end
