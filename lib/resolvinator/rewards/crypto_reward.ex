defmodule Resolvinator.Rewards.CryptoReward do
  @moduledoc """
  Protocol implementation for handling cryptocurrency rewards.
  """

  alias Resolvinator.Rewards.Reward
  alias Money.ExchangeRates

  @doc """
  Creates a new crypto reward.
  """
  def create_crypto_reward(attrs) do
    %Reward{}
    |> Reward.changeset(Map.merge(attrs, %{
      reward_type: :crypto,
      status: :pending
    }))
    |> Resolvinator.Repo.insert()
  end

  @doc """
  Converts a value from one currency to another using current exchange rates.
  """
  def convert_value(value, from_currency, to_currency) do
    with {:ok, rate} <- ExchangeRates.get_rate(from_currency, to_currency) do
      Decimal.mult(value, Decimal.new(rate))
    end
  end

  @doc """
  Validates a blockchain address based on the blockchain type.
  """
  def validate_address(address, blockchain) do
    case blockchain do
      :ethereum -> validate_ethereum_address(address)
      :bitcoin -> validate_bitcoin_address(address)
      :solana -> validate_solana_address(address)
      :polygon -> validate_ethereum_address(address)
      _ -> {:error, "Unsupported blockchain"}
    end
  end

  @doc """
  Formats a reward value based on the currency type.
  """
  def format_value(value, currency) do
    case currency do
      "BTC" -> "#{value} BTC"
      "ETH" -> "#{value} ETH"
      "SOL" -> "#{value} SOL"
      "MATIC" -> "#{value} MATIC"
      "USD" -> "$#{value}"
      _ -> "#{value} #{currency}"
    end
  end

  @doc """
  Gets the current market value of a crypto reward in USD.
  """
  def get_usd_value(value, currency) do
    case currency do
      "USD" -> {:ok, value}
      _ -> convert_value(value, currency, "USD")
    end
  end

  # Private validation functions

  defp validate_ethereum_address(address) do
    if Regex.match?(~r/^0x[a-fA-F0-9]{40}$/, address) do
      {:ok, address}
    else
      {:error, "Invalid Ethereum address format"}
    end
  end

  defp validate_bitcoin_address(address) do
    cond do
      Regex.match?(~r/^[13][a-km-zA-HJ-NP-Z1-9]{25,34}$/, address) ->
        {:ok, address}
      Regex.match?(~r/^bc1[ac-hj-np-z02-9]{11,71}$/, address) ->
        {:ok, address}
      true ->
        {:error, "Invalid Bitcoin address format"}
    end
  end

  defp validate_solana_address(address) do
    if Regex.match?(~r/^[1-9A-HJ-NP-Za-km-z]{32,44}$/, address) do
      {:ok, address}
    else
      {:error, "Invalid Solana address format"}
    end
  end
end
