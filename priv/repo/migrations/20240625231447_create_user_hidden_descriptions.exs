defmodule Resolvinator.Repo.Migrations.CreateUserHiddenDescriptions do
  use Ecto.Migration

  def change do
    create table(:user_hidden_descriptions) do
      add :user_id, references(:users, on_delete: :delete_all)
      add :description_id, references(:descriptions, on_delete: :delete_all)

      timestamps()
    end

    create index(:user_hidden_descriptions, [:user_id])
    create index(:user_hidden_descriptions, [:description_id])
  end
end
