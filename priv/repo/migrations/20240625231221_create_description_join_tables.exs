defmodule Resolvinator.Repo.Migrations.CreateJoinTables do
  use Ecto.Migration

  def change do
    create table(:problem_descriptions) do
      add :problem_id, references(:problems, on_delete: :delete_all)
      add :description_id, references(:descriptions, on_delete: :delete_all)

      timestamps()
    end

    create table(:solution_descriptions) do
      add :solution_id, references(:solutions, on_delete: :delete_all)
      add :description_id, references(:descriptions, on_delete: :delete_all)

      timestamps()
    end

    create table(:lesson_descriptions) do
      add :lesson_id, references(:lessons, on_delete: :delete_all)
      add :description_id, references(:descriptions, on_delete: :delete_all)

      timestamps()
    end

    create table(:advantage_descriptions) do
      add :advantage_id, references(:advantages, on_delete: :delete_all)
      add :description_id, references(:descriptions, on_delete: :delete_all)

      timestamps()
    end
    create table(:gesture_descriptions) do
      add :gesture_id, references(:gestures, on_delete: :delete_all)
      add :description_id, references(:descriptions, on_delete: :delete_all)

      timestamps()
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
