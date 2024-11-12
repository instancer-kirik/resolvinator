defmodule Resolvinator.Repo.Migrations.AddIsHiddenToTopics do
  use Ecto.Migration

  def change do
    alter table(:topics) do
      add :is_hidden, :boolean, default: false
      add :is_private, :boolean, default: false
      add :is_age_restricted, :boolean, default: false
      add :is_premium, :boolean, default: false
  
    end
  end
end