defmodule Resolvinator.Rewards.Reward do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "rewards" do
    field :name, :string
    field :description, :string
    field :value, :integer
    field :status, Ecto.Enum, values: [:pending, :achieved, :expired, :revoked]
    field :achievement_date, :utc_datetime
    field :expiry_date, :utc_datetime
    field :criteria, :map
    field :reward_type, Ecto.Enum, values: [:badge, :achievement, :milestone, :recognition, :risk]
    field :tier, Ecto.Enum, values: [:bronze, :silver, :gold, :platinum]

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

    has_many :prerequisites, Resolvinator.Rewards.RewardPrerequisite
    has_many :reward_claims, Resolvinator.Rewards.RewardClaim

    timestamps(type: :utc_datetime)
  end

  def changeset(reward, attrs) do
    reward
    |> cast(attrs, [
      :name, :description, :value, :status, :achievement_date,
      :expiry_date, :criteria, :reward_type, :tier,
      :probability, :timeline, :dependencies, :metadata,
      :project_id, :achiever_id, :creator_id, :risk_id, :mitigation_id
    ])
    |> validate_required([:name, :value, :status, :reward_type])
    |> validate_risk_reward_fields()
    |> validate_criteria()
    |> foreign_key_constraint(:project_id)
    |> foreign_key_constraint(:achiever_id)
    |> foreign_key_constraint(:creator_id)
    |> foreign_key_constraint(:risk_id)
    |> foreign_key_constraint(:mitigation_id)
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
      |> validate_risk_dependencies()
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

  defimpl Resolvinator.Rewards.RewardProtocol, for: Resolvinator.Rewards.Reward do
    def to_map(reward) do
      %{
        "id" => reward.id,
        "description" => reward.description,
        "value" => reward.value,
        "status" => Atom.to_string(reward.status),
        "reward_type" => Atom.to_string(reward.reward_type),
        "tier" => reward.tier && Atom.to_string(reward.tier),
        "probability" => reward.probability && Atom.to_string(reward.probability),
        "timeline" => reward.timeline && Atom.to_string(reward.timeline),
        "dependencies" => reward.dependencies,
        "metadata" => reward.metadata,
        "achievement_date" => reward.achievement_date,
        "expiry_date" => reward.expiry_date,
        "criteria" => reward.criteria
      }
    end

    def get_attributes(reward) do
      %{
        id: reward.id,
        description: reward.description,
        value: reward.value,
        status: reward.status
      }
    end
  end
end
