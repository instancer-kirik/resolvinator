defmodule Resolvinator.Rewards.Enums do
  @moduledoc """
  Enums for the rewards system
  """

  @reward_types [:badge, :achievement, :milestone, :recognition, :risk]
  @risk_probabilities [:rare, :unlikely, :possible, :likely, :certain]
  @impact_timeframes [:immediate, :short_term, :medium_term, :long_term]
  @reward_statuses [:pending, :achieved, :expired, :revoked]
  @reward_tiers [:bronze, :silver, :gold, :platinum]

  def reward_types, do: @reward_types
  def risk_probabilities, do: @risk_probabilities
  def impact_timeframes, do: @impact_timeframes
  def reward_statuses, do: @reward_statuses
  def reward_tiers, do: @reward_tiers

  @doc """
  Validates that a value is a valid reward type
  """
  def valid_reward_type?(type) when type in @reward_types, do: true
  def valid_reward_type?(_), do: false

  @doc """
  Validates that a value is a valid risk probability
  """
  def valid_risk_probability?(prob) when prob in @risk_probabilities, do: true
  def valid_risk_probability?(_), do: false

  @doc """
  Validates that a value is a valid impact timeframe
  """
  def valid_impact_timeframe?(frame) when frame in @impact_timeframes, do: true
  def valid_impact_timeframe?(_), do: false

  @doc """
  Validates that a value is a valid reward status
  """
  def valid_reward_status?(status) when status in @reward_statuses, do: true
  def valid_reward_status?(_), do: false

  @doc """
  Validates that a value is a valid reward tier
  """
  def valid_reward_tier?(tier) when tier in @reward_tiers, do: true
  def valid_reward_tier?(_), do: false
end
