defmodule Resolvinator.Repo.Migrations.CreateJoinTables do
  use Ecto.Migration

  def change do
    create table(:problem_descriptions, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :problem_id, references(:problems, on_delete: :delete_all)
      add :description_id, references(:descriptions, on_delete: :delete_all)

      timestamps(type: :utc_datetime)
    end

    create table(:solution_descriptions, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :solution_id, references(:solutions, on_delete: :delete_all)
      add :description_id, references(:descriptions, on_delete: :delete_all)

      timestamps(type: :utc_datetime)
    end

    create table(:lesson_descriptions, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :lesson_id, references(:lessons, on_delete: :delete_all)
      add :description_id, references(:descriptions, on_delete: :delete_all)

      timestamps(type: :utc_datetime)
    end

    create table(:advantage_descriptions, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :advantage_id, references(:advantages, on_delete: :delete_all)
      add :description_id, references(:descriptions, on_delete: :delete_all)

      timestamps(type: :utc_datetime)
    end
    create table(:gesture_descriptions, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :gesture_id, references(:gestures, on_delete: :delete_all)
      add :description_id, references(:descriptions, on_delete: :delete_all)

      timestamps(type: :utc_datetime)
    end
    create unique_index(:gesture_descriptions, [:gesture_id, :description_id])
    create index(:problem_descriptions, [:problem_id])
    create index(:problem_descriptions, [:description_id])

    create index(:solution_descriptions, [:solution_id])
    create index(:solution_descriptions, [:description_id])

    create index(:lesson_descriptions, [:lesson_id])
    create index(:lesson_descriptions, [:description_id])

    create index(:advantage_descriptions, [:advantage_id])
    create index(:advantage_descriptions, [:description_id])
  end
end
