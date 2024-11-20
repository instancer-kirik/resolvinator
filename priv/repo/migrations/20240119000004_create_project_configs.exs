defmodule Resolvinator.Repo.Migrations.CreateProjectConfigs do
  use Ecto.Migration

  def change do
    create table(:project_configs) do
      add :name, :string, null: false
      add :description, :text
      add :development_env, :map
      add :code_style, :map
      add :testing, :map
      add :documentation, :map
      add :security, :map
      add :project_commands, :map
      add :system_id, references(:systems, on_delete: :delete_all), null: false

      timestamps()
    end

    create index(:project_configs, [:system_id])
    create unique_index(:project_configs, [:name, :system_id])
  end
end
