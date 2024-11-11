defmodule Resolvinator.Repo.Migrations.CreateGestures do
  use Ecto.Migration

  def change do
    create table(:gestures, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :id, :binary_id, primary_key: true
      add :name, :string
      add :descriptions, {:array, :string}, default: []
      add :svg, :text
      add :fingers, :string

      timestamps(type: :utc_datetime)
    end
  end
end
