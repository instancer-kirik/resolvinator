defmodule Resolvinator.Ships do
  @moduledoc """
  The Ships context.
  """

  import Ecto.Query, warn: false
  alias Resolvinator.Repo
  alias Resolvinator.Ships.Ship

  def list_ships do
    Repo.all(Ship)
  end

  def get_ship!(id), do: Repo.get!(Ship, id)

  def get_project_ship(project_id) do
    Repo.get_by(Ship, project_id: project_id)
  end

  def create_ship(attrs \\ %{}) do
    %Ship{}
    |> Ship.changeset(attrs)
    |> Repo.insert()
  end

  def update_ship(%Ship{} = ship, attrs) do
    ship
    |> Ship.changeset(attrs)
    |> Repo.update()
  end

  def delete_ship(%Ship{} = ship) do
    Repo.delete(ship)
  end

  def change_ship(%Ship{} = ship, attrs \\ %{}) do
    Ship.changeset(ship, attrs)
  end

  # Ship Operations
  
  def launch_ship(%Ship{} = ship) do
    ship
    |> Ship.set_sail()
    |> Repo.update()
  end

  def dock_ship(%Ship{} = ship) do
    ship
    |> Ship.dock()
    |> Repo.update()
  end

  def repair_ship(%Ship{} = ship, amount) do
    ship
    |> Ship.repair(amount)
    |> Repo.update()
  end
end 