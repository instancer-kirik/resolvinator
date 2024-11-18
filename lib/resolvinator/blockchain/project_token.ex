defmodule Resolvinator.Blockchain.ProjectToken do
  @moduledoc """
  Handles project tokenization, trading, and staking.
  Each project can be minted as an NFT, and users can also stake tokens for project governance.
  """
  
  use Ecto.Schema
  import Ecto.Changeset
  import Ecto.Query
  alias Resolvinator.Repo
  alias Resolvinator.Projects.Project
  alias Resolvinator.Accounts.User

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "project_tokens" do
    field :token_id, :string  # Unique token ID on the blockchain
    field :token_uri, :string # Metadata URI (IPFS)
    field :token_type, :string # "nft" or "governance"
    field :amount, :decimal   # For governance tokens
    field :staked_amount, :decimal, default: Decimal.new(0)
    field :stake_start_time, :utc_datetime
    field :stake_end_time, :utc_datetime
    field :metadata, :map     # Project-specific metadata
    
    belongs_to :project, Project
    belongs_to :owner, User
    
    timestamps()
  end

  @doc """
  Creates a new NFT for a project.
  """
  def mint_nft(project, owner) do
    # Generate unique token ID using project details and timestamp
    token_id = generate_token_id(project)
    
    # Store project metadata on IPFS (mock for now)
    token_uri = generate_ipfs_uri(project)
    
    %__MODULE__{}
    |> changeset(%{
      token_id: token_id,
      token_uri: token_uri,
      token_type: "nft",
      amount: Decimal.new(1),
      metadata: %{
        name: project.name,
        description: project.description,
        attributes: [
          %{trait_type: "Status", value: project.status},
          %{trait_type: "Risk Appetite", value: project.risk_appetite}
        ]
      }
    })
    |> put_assoc(:project, project)
    |> put_assoc(:owner, owner)
    |> Repo.insert()
  end

  @doc """
  Mints governance tokens for a project.
  """
  def mint_governance_tokens(project, owner, amount) do
    %__MODULE__{}
    |> changeset(%{
      token_id: "gov_#{generate_token_id(project)}",
      token_type: "governance",
      amount: amount,
      metadata: %{
        name: "#{project.name} Governance Token",
        description: "Governance token for #{project.name}",
        decimals: 18
      }
    })
    |> put_assoc(:project, project)
    |> put_assoc(:owner, owner)
    |> Repo.insert()
  end

  @doc """
  Stakes governance tokens for a project.
  """
  def stake_tokens(token, amount, duration_days) do
    now = DateTime.utc_now()
    end_time = DateTime.add(now, duration_days * 24 * 60 * 60, :second)

    token
    |> changeset(%{
      staked_amount: Decimal.add(token.staked_amount, amount),
      stake_start_time: now,
      stake_end_time: end_time
    })
    |> Repo.update()
  end

  @doc """
  Transfers token ownership to a new user.
  """
  def transfer(token, new_owner) do
    token
    |> changeset(%{})
    |> put_assoc(:owner, new_owner)
    |> Repo.update()
  end

  @doc """
  Lists all tokens owned by a user.
  """
  def list_user_tokens(user_id) do
    from(t in __MODULE__,
      where: t.owner_id == ^user_id,
      preload: [:project]
    )
    |> Repo.all()
  end

  @doc """
  Gets the voting power of a user for a project based on staked tokens.
  """
  def get_voting_power(user_id, project_id) do
    from(t in __MODULE__,
      where: t.owner_id == ^user_id and
             t.project_id == ^project_id and
             t.token_type == "governance" and
             t.stake_end_time > ^DateTime.utc_now(),
      select: sum(t.staked_amount)
    )
    |> Repo.one() || Decimal.new(0)
  end

  defp changeset(token, attrs) do
    token
    |> cast(attrs, [:token_id, :token_uri, :token_type, :amount, 
                   :staked_amount, :stake_start_time, :stake_end_time, :metadata])
    |> validate_required([:token_id, :token_type])
    |> validate_inclusion(:token_type, ["nft", "governance"])
    |> unique_constraint(:token_id)
  end

  defp generate_token_id(project) do
    timestamp = System.system_time(:millisecond)
    "#{project.id}_#{timestamp}"
    |> Base.encode16(case: :lower)
  end

  defp generate_ipfs_uri(project) do
    # Mock IPFS URI generation (in production, would actually upload to IPFS)
    "ipfs://Qm#{Base.encode16(:crypto.strong_rand_bytes(32), case: :lower)}"
  end
end
