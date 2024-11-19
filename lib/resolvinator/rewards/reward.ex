defmodule Resolvinator.Rewards.Reward do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "rewards" do
    field :name, :string
    field :description, :string
    field :value, :decimal
    field :currency, :string, default: "ETH"  # Can be USD, BTC, ETH, etc.
    field :status, Ecto.Enum, values: [:pending, :achieved, :expired, :revoked]
    field :achievement_date, :utc_datetime
    field :expiry_date, :utc_datetime
    field :criteria, :map
    field :reward_type, Ecto.Enum, values: [:badge, :achievement, :milestone, :recognition, :risk, :crypto]
    field :tier, Ecto.Enum, values: [:bronze, :silver, :gold, :platinum]

    # Crypto reward specific fields
    field :wallet_address, :string
    field :transaction_hash, :string
    field :blockchain, Ecto.Enum, values: [:ethereum, :bitcoin, :solana, :polygon]
    field :token_contract, :string
    field :token_id, :string  # For NFTs
    field :token_standard, Ecto.Enum, values: [:erc20, :erc721, :erc1155, :native]

    # Risk reward specific fields
    field :probability, Ecto.Enum, values: [:rare, :unlikely, :possible, :likely, :certain]
    field :timeline, Ecto.Enum, values: [:immediate, :short_term, :medium_term, :long_term]
    field :dependencies, {:array, :binary_id}, default: []
    field :metadata, :map, default: %{}

    belongs_to :project, Resolvinator.Projects.Project
    belongs_to :achiever, Resolvinator.Accounts.User
    belongs_to :creator, Resolvinator.Accounts.User
    belongs_to :risk, Resolvinator.Risks.Risk
    belongs_to :mitigation, Resolvinator.Risks.Mitigation
    belongs_to :resource, Resolvinator.Resources.Resource

    has_many :prerequisites, Resolvinator.Rewards.RewardPrerequisite
    has_many :reward_claims, Resolvinator.Rewards.RewardClaim

    timestamps(type: :utc_datetime)
  end

  def changeset(reward, attrs) do
    reward
    |> cast(attrs, [
      :name, :description, :value, :currency, :status, :achievement_date,
      :expiry_date, :criteria, :reward_type, :tier,
      :wallet_address, :transaction_hash, :blockchain, :token_contract,
      :token_id, :token_standard,
      :probability, :timeline, :dependencies, :metadata,
      :project_id, :achiever_id, :creator_id, :risk_id, :mitigation_id,
      :resource_id
    ])
    |> validate_required([:name, :value, :currency, :status, :reward_type])
    |> validate_risk_reward_fields()
    |> validate_crypto_reward_fields()
    |> validate_criteria()
    |> foreign_key_constraint(:project_id)
    |> foreign_key_constraint(:achiever_id)
    |> foreign_key_constraint(:creator_id)
    |> foreign_key_constraint(:risk_id)
    |> foreign_key_constraint(:mitigation_id)
    |> foreign_key_constraint(:resource_id)
  end

  def risk_reward_changeset(reward, attrs) do
    reward
    |> changeset(Map.put(attrs, "reward_type", :risk))
    |> validate_required([:probability, :timeline])
  end

  defp validate_risk_reward_fields(changeset) do
    if get_field(changeset, :reward_type) == :risk do
      changeset
      |> validate_required([:probability, :timeline])
      |> validate_change(:dependencies, fn :dependencies, dependencies ->
        if Enum.empty?(dependencies), do: [dependencies: "Risk rewards must have dependencies"], else: []
      end)
    else
      changeset
    end
  end

  defp validate_crypto_reward_fields(changeset) do
    if get_field(changeset, :reward_type) == :crypto do
      changeset
      |> validate_required([:blockchain, :token_standard])
      |> validate_wallet_address()
      |> validate_token_fields()
    else
      changeset
    end
  end

  defp validate_risk_dependencies(changeset) do
    case get_field(changeset, :dependencies) do
      nil -> changeset
      deps when is_list(deps) -> changeset
      _ -> add_error(changeset, :dependencies, "must be a list of IDs")
    end
  end

  defp validate_criteria(changeset) do
    case get_field(changeset, :criteria) do
      nil -> changeset
      criteria when is_map(criteria) -> changeset
      _ -> add_error(changeset, :criteria, "must be a map")
    end
  end

end
