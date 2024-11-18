defmodule Resolvinator.Blockchain.GovernanceProposal do
  @moduledoc """
  Schema and functions for DAO governance proposals.
  Similar to MakerDAO's governance polls.
  """
  
  use Ecto.Schema
  import Ecto.Changeset
  alias Resolvinator.Accounts.User
  alias Resolvinator.Blockchain.{ProjectDAO, Vote}

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "governance_proposals" do
    field :title, :string
    field :description, :string
    field :changes, :map        # Proposed parameter changes
    field :end_time, :utc_datetime
    field :executed, :boolean, default: false
    field :total_votes_for, :decimal, default: Decimal.new(0)
    field :total_votes_against, :decimal, default: Decimal.new(0)
    
    belongs_to :dao, ProjectDAO
    belongs_to :proposer, User
    has_many :votes, Vote
    
    timestamps()
  end

  def changeset(proposal, attrs) do
    proposal
    |> cast(attrs, [:title, :description, :changes, :end_time, :executed,
                   :total_votes_for, :total_votes_against])
    |> validate_required([:title, :description, :changes, :end_time])
    |> validate_change(:end_time, &validate_future_time/2)
  end

  defp validate_future_time(:end_time, end_time) do
    case DateTime.compare(end_time, DateTime.utc_now()) do
      :gt -> []
      _ -> [end_time: "must be in the future"]
    end
  end
end

defmodule Resolvinator.Blockchain.Vote do
  @moduledoc """
  Schema for votes on governance proposals.
  """
  
  use Ecto.Schema
  import Ecto.Changeset
  alias Resolvinator.Accounts.User
  alias Resolvinator.Blockchain.GovernanceProposal

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "governance_votes" do
    field :support, :boolean    # true for support, false against
    field :voting_power, :decimal
    
    belongs_to :proposal, GovernanceProposal
    belongs_to :voter, User
    
    timestamps()
  end

  def changeset(vote, attrs) do
    vote
    |> cast(attrs, [:support, :voting_power])
    |> validate_required([:support, :voting_power])
    |> validate_number(:voting_power, greater_than: 0)
  end
end
