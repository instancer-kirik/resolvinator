defmodule Resolvinator.Blockchain.ProjectCollateralPosition do
  @moduledoc """
  Schema and functions for Project Collateral Positions (PCPs).
  Similar to MakerDAO's CDPs but using project tokens as collateral.
  """
  
  use Ecto.Schema
  import Ecto.Changeset
  alias Resolvinator.Accounts.User
  alias Resolvinator.Blockchain.ProjectDAO

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "project_collateral_positions" do
    field :collateral_amount, :decimal
    field :debt_amount, :decimal
    field :liquidation_price, :decimal
    field :status, :string, default: "active"  # active, repaid, liquidated
    
    belongs_to :dao, ProjectDAO
    belongs_to :owner, User
    
    timestamps()
  end

  def changeset(position, attrs) do
    position
    |> cast(attrs, [:collateral_amount, :debt_amount, :liquidation_price, :status])
    |> validate_required([:collateral_amount, :debt_amount, :liquidation_price])
    |> validate_number(:collateral_amount, greater_than: 0)
    |> validate_number(:debt_amount, greater_than: 0)
    |> validate_inclusion(:status, ~w(active repaid liquidated))
  end
end
