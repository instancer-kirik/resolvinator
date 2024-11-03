defmodule Resolvinator.Rewards.RewardPrerequisite do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "reward_prerequisites" do
    field :required_count, :integer, default: 1

    belongs_to :reward, Resolvinator.Rewards.Reward
    belongs_to :required_reward, Resolvinator.Rewards.Reward

    timestamps()
  end

  def changeset(prerequisite, attrs) do
    prerequisite
    |> cast(attrs, [:required_count, :reward_id, :required_reward_id])
    |> validate_required([:required_count, :reward_id, :required_reward_id])
    |> validate_number(:required_count, greater_than: 0)
    |> foreign_key_constraint(:reward_id)
    |> foreign_key_constraint(:required_reward_id)
  end
end
