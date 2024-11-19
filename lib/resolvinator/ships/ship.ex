defmodule Resolvinator.Ships.Ship do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  @vessel_classes ~w(sloop brigantine galleon frigate schooner)

  schema "ships" do
    field :name, :string
    field :vessel_class, :string, default: "sloop"
    field :flag, :string
    field :crew_capacity, :integer, default: 1
    field :tonnage, :integer, default: 100
    # Ship stats
    field :hull_integrity, :float, default: 100.0
    field :crew_morale, :float, default: 100.0
    field :supplies, :float, default: 100.0
    
    # Navigation
    field :position, :map, default: %{x: 0.0, y: 0.0}
    field :heading, :float, default: 0.0
    field :speed, :float, default: 0.0

    # Timestamps
    field :launched_at, :utc_datetime
    field :last_docked_at, :utc_datetime
    
    # Relationships
    belongs_to :project, Resolvinator.Projects.Project
    has_many :crew_members, Resolvinator.Ships.CrewMember
    
    # Presentation Strategy
    field :showcase_type, :string  # video, interactive, github, wings
    field :showcase_data, :map, default: %{
      "video_url" => nil,
      "demo_url" => nil,
      "github_url" => nil,
      "slides_url" => nil
    }
    
    # Wing-based showcase structure
    field :wing_showcase, {:array, :map}, default: []
    # Project highlights
    field :key_features, {:array, :string}, default: []
    field :tech_stack, {:array, :string}, default: []
    # Battle Stats
    field :battles_won, :integer, default: 0
    field :battles_participated, :integer, default: 0
    field :total_feedback_received, :integer, default: 0
    
    has_many :battle_appearances, Resolvinator.Wonderdome.BattleShip
    
    timestamps(type: :utc_datetime)
  end
end 