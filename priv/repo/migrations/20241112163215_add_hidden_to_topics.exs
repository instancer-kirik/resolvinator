defmodule Resolvinator.Repo.Migrations.AddIsHiddenToTopics do
  use Ecto.Migration

  def change do
    alter table(:topics) do
      add :is_hidden, :boolean, default: false
    end
  end
end