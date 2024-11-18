defmodule Resolvinator.Wonderdome.Battle do
  use Ecto.Schema
  import Ecto.Changeset

  schema "wonderdome_battles" do
    field :status, :string, default: "preparing"
    field :title, :string
    field :description, :string
    
    # Battle duration
    field :scheduled_start, :utc_datetime
    field :scheduled_end, :utc_datetime
    
    # Only two ships per battle
    belongs_to :ship_one, Resolvinator.Ships.Ship
    belongs_to :ship_two, Resolvinator.Ships.Ship
    
    # Voting and feedback
    has_many :votes, Resolvinator.Wonderdome.Vote
    has_many :feedback_items, Resolvinator.Wonderdome.Feedback
    
    # Results
    field :winner_id, :binary_id
    field :vote_counts, :map, default: %{}
    
    timestamps(type: :utc_datetime)
  end
end

defmodule Resolvinator.Wonderdome.Vote do
  use Ecto.Schema
  
  schema "wonderdome_votes" do
    belongs_to :battle, Resolvinator.Wonderdome.Battle
    belongs_to :user, Resolvinator.Accounts.User
    belongs_to :ship, Resolvinator.Ships.Ship
    
    field :categories, :map, default: %{
      "innovation" => 0,
      "execution" => 0,
      "presentation" => 0,
      "potential" => 0
    }
    
    timestamps(type: :utc_datetime)
  end
end

defmodule Resolvinator.Wonderdome.Feedback do
  use Ecto.Schema
  
  schema "wonderdome_feedback" do
    belongs_to :battle, Resolvinator.Wonderdome.Battle
    belongs_to :user, Resolvinator.Accounts.User
    belongs_to :ship, Resolvinator.Ships.Ship
    
    field :type, :string  # praise, suggestion, question
    field :content, :string
    field :category, :string  # code, design, concept, etc
    field :anonymous, :boolean, default: false
    
    timestamps(type: :utc_datetime)
  end
end

defmodule Resolvinator.Wonderdome.BattleShip do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "wonderdome_battle_ships" do
    belongs_to :battle, Resolvinator.Wonderdome.Battle
    belongs_to :ship, Resolvinator.Ships.Ship
    
    field :position, :map, default: %{x: 0, y: 0, z: 0}
    field :ready_status, :boolean, default: false
    field :score, :map, default: %{
      "innovation" => 0,
      "technical_execution" => 0,
      "presentation" => 0,
      "impact" => 0
    }

    timestamps(type: :utc_datetime)
  end
end

defmodule Resolvinator.Wonderdome.Volley do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "wonderdome_volleys" do
    belongs_to :battle, Resolvinator.Wonderdome.Battle
    belongs_to :from_ship, Resolvinator.Ships.Ship
    belongs_to :to_ship, Resolvinator.Ships.Ship
    belongs_to :user, Resolvinator.Accounts.User
    
    field :feedback_type, :string # praise, criticism, question, suggestion
    field :content, :string
    field :category, :string # code, design, presentation, etc
    field :impact_score, :integer # 1-5
    
    # Optional code snippet or area reference
    field :context, :map

    timestamps(type: :utc_datetime)
  end 