defmodule Resolvinator.Repo.Migrations.AddModerationToAdvantage do
  use Ecto.Migration

  def change do
    alter table(:advantages) do
      add :status, :string, default: "initial"
      add :rejection_reason, :string
    end
  end
end
