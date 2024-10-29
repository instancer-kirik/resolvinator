defmodule Resolvinator.Repo.Migrations.AddModerationToProblem do
  use Ecto.Migration

  def change do
    alter table(:problems) do
      add :status, :string, default: "initial"
      add :rejection_reason, :string
    end
  end
end
