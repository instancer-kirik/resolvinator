defmodule Resolvinator.Rewards.Types do
  @moduledoc """
  Type specifications for the rewards system
  """

  @type reward_type :: :badge | :achievement | :milestone | :recognition | :risk
  @type risk_probability :: :rare | :unlikely | :possible | :likely | :certain
  @type impact_timeframe :: :immediate | :short_term | :medium_term | :long_term
  @type reward_status :: :pending | :achieved | :expired | :revoked
  @type reward_tier :: :bronze | :silver | :gold | :platinum

  @type reward_attributes :: %{
    id: binary(),
    description: String.t(),
    value: float(),
    status: reward_status(),
    reward_type: reward_type(),
    tier: reward_tier() | nil,
    probability: risk_probability() | nil,
    timeline: impact_timeframe() | nil,
    dependencies: [binary()],
    metadata: map()
  }
end
