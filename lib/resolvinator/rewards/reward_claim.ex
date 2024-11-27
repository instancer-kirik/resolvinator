defmodule Resolvinator.Rewards.RewardClaim do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "reward_claims" do
    field :status, Ecto.Enum, values: [:pending, :approved, :rejected]
    field :evidence, :map
    field :reviewed_at, :utc_datetime

    belongs_to :reward, Resolvinator.Rewards.Reward
    belongs_to :user, Resolvinator.Acts.User
    belongs_to :reviewer, Resolvinator.Acts.User, foreign_key: :reviewed_by_id

    timestamps()
  end

  def changeset(claim, attrs) do
    claim
    |> cast(attrs, [:status, :evidence, :reviewed_at, :reward_id, :user_id, :reviewed_by_id])
    |> validate_required([:status, :evidence, :reward_id, :user_id])
    |> foreign_key_constraint(:reward_id)
    |> foreign_key_constraint(:user_id)
    |> foreign_key_constraint(:reviewed_by_id)
  end
end
