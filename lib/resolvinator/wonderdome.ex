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

  defp generate_starting_position(battle) do
    # Generate a random position within the battle area
    %{
      x: :rand.uniform(100),
      y: :rand.uniform(100),
      rotation: :rand.uniform(360)
    }
  end

  defp calculate_duration(battle) do
    case {battle.started_at, battle.ended_at} do
      {nil, _} -> 0
      {_, nil} -> DateTime.diff(DateTime.utc_now(), battle.started_at)
      {start, finish} -> DateTime.diff(finish, start)
    end
  end

  defp summarize_volleys(volleys) do
    volleys
    |> Enum.group_by(& &1.from_ship_id)
    |> Enum.map(fn {ship_id, ship_volleys} ->
      %{
        ship_id: ship_id,
        total_volleys: length(ship_volleys),
        hits: Enum.count(ship_volleys, & &1.hit),
        total_damage: Enum.sum(Enum.map(ship_volleys, & &1.damage || 0))
      }
    end)
  end

  defp identify_strong_categories(battle_ship) do
    # Analyze the ship's performance across different categories
    categories = [:accuracy, :damage, :survival]

    categories
    |> Enum.filter(fn category ->
      score = get_category_score(battle_ship, category)
      score > 7.0  # Consider scores above 7.0 as strong
    end)
  end

  defp count_feedback_received(battle_ship) do
    # Count the number of feedback entries received
    Repo.one(
      from f in "battle_feedback",
      where: f.battle_ship_id == ^battle_ship.id,
      select: count(f.id)
    ) || 0
  end

  defp calculate_total_score(score) when is_map(score), do: Map.get(score, :total, 0)
  defp calculate_total_score(_), do: 0

  defp get_category_score(battle_ship, category) do
    battle_ship.score
    |> Map.get(Atom.to_string(category), 0)
  end
end
