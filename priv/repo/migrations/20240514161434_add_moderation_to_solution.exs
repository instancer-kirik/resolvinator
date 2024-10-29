defmodule Resolvinator.Repo.Migrations.AddModerationToSolution do
  use Ecto.Migration

  def change do
    alter table(:solutions) do
      add :status, :string, default: "initial"
      add :rejection_reason, :string
    end
  end
end
