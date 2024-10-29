defmodule Resolvinator.Repo.Migrations.CreateGestures do
  use Ecto.Migration

  def change do
    create table(:gestures) do
      add :name, :string
      add :descriptions, {:array, :string}, default: []
      add :svg, :text
      add :fingers, :string

      timestamps(type: :utc_datetime)
    end
  end
end
