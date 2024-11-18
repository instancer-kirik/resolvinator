defmodule Resolvinator.Wonderdome do
  import Ecto.Query
  alias Resolvinator.Repo
  alias Resolvinator.Wonderdome.{Battle, BattleShip, Volley}
  alias Resolvinator.Ships

  def create_battle(attrs \\ %{}) do
    %Battle{}
    |> Battle.changeset(attrs)
    |> Repo.insert()
  end

  def add_ship_to_battle(battle, ship) do
    %BattleShip{}
    |> BattleShip.changeset(%{
      battle_id: battle.id,
      ship_id: ship.id,
      position: generate_starting_position(battle)
    })
    |> Repo.insert()
  end

  def fire_volley(attrs) do
    %Volley{}
    |> Volley.changeset(attrs)
    |> Repo.insert()
  end

  def get_battle_stats(battle_id) do
    battle = Repo.get!(Battle, battle_id)
    |> Repo.preload([
      :battle_ships,
      volleys: [:from_ship, :to_ship, :user]
    ])

    %{
      ships: battle.battle_ships |> Enum.map(&summarize_ship_performance/1),
      volleys: summarize_volleys(battle.volleys),
      duration: calculate_duration(battle)
    }
  end

  defp summarize_ship_performance(battle_ship) do
    %{
      ship_id: battle_ship.ship_id,
      total_score: calculate_total_score(battle_ship.score),
      feedback_received: count_feedback_received(battle_ship),
      strongest_categories: identify_strong_categories(battle_ship)
    }
  end

  defp calculate_total_score(score) do
    score
    |> Map.values()
    |> Enum.sum()
  end

  # Additional helper functions...
end 