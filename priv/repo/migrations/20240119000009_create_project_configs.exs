defmodule Resolvinator.Repo.Migrations.CreateProjectConfigs do
  use Ecto.Migration

  def change do
    create table(:project_configs) do
      add :environment_type, :string, default: "development"
      add :virtual_env_path, :string
      add :workspace_path, :string
      add :file_extensions, {:array, :string}, default: [".ex", ".exs", ".eex"]
      add :excluded_dirs, {:array, :string}, default: ["_build", "deps", ".git"]
      add :required_tools, {:array, :string}, default: []
      add :tool_versions, :map, default: %{}

      add :code_style, :map, default: %{
        "style_guide" => "elixir_style",
        "max_complexity" => 10,
        "formatters" => ["mix format"],
        "linters" => ["credo"]
      }

      add :testing, :map, default: %{
        "framework" => "exunit",
        "coverage_target" => 80,
        "strategies" => ["unit", "integration"],
        "performance_benchmarks" => %{}
      }

      add :documentation, :map, default: %{
        "required_sections" => ["API", "Setup", "Usage"],
        "format" => "markdown",
        "tools" => ["ex_doc"]
      }

      add :security, :map, default: %{
        "requirements" => [],
        "scan_frequency" => "weekly",
        "vulnerability_threshold" => "high"
      }

      add :commands, :map, default: %{
        "build" => "mix compile",
        "run" => "mix run",
        "test" => "mix test"
      }

      add :system_id, references(:systems, type: :binary_id), null: false
      # Note: creator_id references resolvinator_accounts_fdw.users but we cannot use a foreign key
      # constraint because PostgreSQL does not support foreign keys to foreign tables.
      # Referential integrity will be handled at the application level.
      add :creator_id, :binary_id, null: false

      timestamps(type: :utc_datetime)
    end

    create index(:project_configs, [:creator_id])
    create unique_index(:project_configs, [:system_id])
  end
end
