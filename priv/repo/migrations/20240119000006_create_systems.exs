defmodule Resolvinator.Repo.Migrations.CreateSystems do
  use Ecto.Migration

  def change do
    create table(:systems, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :name, :string, null: false
      add :description, :string
      add :system_type, :string, null: false
      add :lifecycle_stage, :string, null: false
      add :version, :string
      add :technical_stack, {:array, :string}, default: []
      add :dependencies, {:array, :string}, default: []
      add :environment_type, :string, null: false
      add :os_type, :string
      add :os_version, :string
      add :root_path, :string
      add :environment_variables, :map, default: %{}
      add :filesystem_config, :map, default: %{
        "paths" => %{
          "data" => nil,
          "logs" => nil,
          "config" => nil,
          "temp" => nil,
          "backup" => nil
        },
        "permissions" => %{
          "owner" => nil,
          "group" => nil,
          "mode" => nil
        },
        "mount_points" => [],
        "storage_quotas" => %{
          "max_size" => nil,
          "warning_threshold" => nil
        }
      }
      add :configuration, :map, default: %{}
      add :health_metrics, :map, default: %{
        "availability" => 0.0,
        "reliability" => 0.0,
        "performance" => 0.0,
        "security_score" => 0.0,
        "maintainability" => 0.0
      }
      add :documentation_url, :string
      add :status, :string, default: "active"
      add :metadata, :map, default: %{}

      # References
      add :project_id, references(:projects, type: :binary_id), null: false
      # Note: creator_id references resolvinator_accounts_fdw.users but we cannot use a foreign key
      # constraint because PostgreSQL does not support foreign keys to foreign tables.
      # Referential integrity will be handled at the application level.
      add :creator_id, :binary_id, null: false

      timestamps(type: :utc_datetime)
    end

    create index(:systems, [:project_id])
    create index(:systems, [:creator_id])
    create unique_index(:systems, [:name, :project_id])

    # Create the many-to-many relationship for maintainers
    create table(:system_maintainers, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :system_id, references(:systems, type: :binary_id), null: false
      # Note: user_id references resolvinator_accounts_fdw.users but we cannot use a foreign key
      # constraint because PostgreSQL does not support foreign keys to foreign tables.
      # Referential integrity will be handled at the application level.
      add :user_id, :binary_id, null: false

      timestamps(type: :utc_datetime)
    end

    create unique_index(:system_maintainers, [:system_id, :user_id])

    # Create the many-to-many relationship for related systems
    create table(:system_relationships, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :system_id, references(:systems, type: :binary_id), null: false
      add :related_system_id, references(:systems, type: :binary_id), null: false
      add :relationship_type, :string, null: false

      timestamps(type: :utc_datetime)
    end

    create unique_index(:system_relationships, [:system_id, :related_system_id])
  end
end
