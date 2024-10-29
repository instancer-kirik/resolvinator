defmodule Resolvinator.Repo.Migrations.AddModerationToLesson do
  use Ecto.Migration

  def change do
    alter table(:lessons) do
      add :status, :string, default: "initial"
      add :rejection_reason, :string
    end
  end
end
