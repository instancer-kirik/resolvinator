defmodule Resolvinator.Repo.Migrations.CreateAuthors do
  use Ecto.Migration

  def change do
    create table(:authors) do
      add :username, :string, null: false
      add :email, :string, null: false

      timestamps()
    end

    create unique_index(:authors, [:username])
    create unique_index(:authors, [:email])
  end
end
