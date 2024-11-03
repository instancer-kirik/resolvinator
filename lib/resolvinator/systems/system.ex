defmodule Resolvinator.Systems.System do
  use Ecto.Schema
  import Ecto.Changeset

  @system_types ~w(software hardware infrastructure service hybrid)
  @lifecycle_stages ~w(concept development testing production maintenance eol)
  @os_types ~w(linux windows macos unix other)
  @env_types ~w(development staging production testing)

  schema "systems" do
    field :name, :string
    field :description, :string
    field :system_type, :string
    field :lifecycle_stage, :string
    field :version, :string
    field :technical_stack, {:array, :string}
    field :dependencies, {:array, :string}
    field :environment_type, :string
    field :os_type, :string
    field :os_version, :string
    field :root_path, :string
    field :environment_variables, :map, default: %{}
    field :filesystem_config, :map, default: %{
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
    field :configuration, :map, default: %{}
    field :health_metrics, :map, default: %{
      "availability" => 0.0,
      "reliability" => 0.0,
      "performance" => 0.0,
      "security_score" => 0.0,
      "maintainability" => 0.0
    }
    field :documentation_url, :string
    field :status, :string, default: "active"
    field :metadata, :map, default: %{}

    # Relationships
    belongs_to :project, Resolvinator.Projects.Project
    belongs_to :owner, Resolvinator.Accounts.User
    has_many :components, Resolvinator.Systems.Component
    has_many :incidents, Resolvinator.Systems.Incident
    has_many :maintenance_records, Resolvinator.Systems.MaintenanceRecord
    has_many :filesystem_entries, Resolvinator.Systems.FilesystemEntry
    
    many_to_many :related_systems, __MODULE__,
      join_through: "system_relationships",
      join_keys: [system_id: :id, related_system_id: :id]

    many_to_many :maintainers, Resolvinator.Accounts.User,
      join_through: "system_maintainers"

    timestamps(type: :utc_datetime)
  end

  def changeset(system, attrs) do
    system
    |> cast(attrs, [
      :name, :description, :system_type, :lifecycle_stage,
      :version, :technical_stack, :dependencies, :configuration,
      :health_metrics, :documentation_url, :status, :metadata,
      :project_id, :owner_id, :environment_type, :os_type,
      :os_version, :root_path, :environment_variables,
      :filesystem_config
    ])
    |> validate_required([
      :name, :system_type, :lifecycle_stage,
      :project_id, :owner_id, :environment_type
    ])
    |> validate_inclusion(:system_type, @system_types)
    |> validate_inclusion(:lifecycle_stage, @lifecycle_stages)
    |> validate_inclusion(:environment_type, @env_types)
    |> validate_inclusion(:os_type, @os_types)
    |> validate_health_metrics()
    |> validate_filesystem_config()
    |> validate_root_path()
    |> foreign_key_constraint(:project_id)
    |> foreign_key_constraint(:owner_id)
  end

  defp validate_health_metrics(changeset) do
    case get_change(changeset, :health_metrics) do
      nil -> changeset
      metrics ->
        if valid_health_metrics?(metrics) do
          changeset
        else
          add_error(changeset, :health_metrics, "invalid health metrics structure")
        end
    end
  end

  defp valid_health_metrics?(metrics) do
    required_metrics = ~w(availability reliability performance security_score maintainability)
    Enum.all?(required_metrics, &(is_number(Map.get(metrics, &1, 0.0))))
  end

  defp validate_filesystem_config(changeset) do
    case get_change(changeset, :filesystem_config) do
      nil -> changeset
      config ->
        if valid_filesystem_config?(config) do
          changeset
        else
          add_error(changeset, :filesystem_config, "invalid filesystem configuration")
        end
    end
  end

  defp valid_filesystem_config?(config) do
    required_sections = ~w(paths permissions mount_points storage_quotas)
    required_paths = ~w(data logs config temp backup)
    required_permissions = ~w(owner group mode)

    with true <- is_map(config),
         true <- Enum.all?(required_sections, &Map.has_key?(config, &1)),
         paths = Map.get(config, "paths"),
         true <- Enum.all?(required_paths, &Map.has_key?(paths, &1)),
         perms = Map.get(config, "permissions"),
         true <- Enum.all?(required_permissions, &Map.has_key?(perms, &1)),
         true <- is_list(Map.get(config, "mount_points")),
         quotas = Map.get(config, "storage_quotas"),
         true <- Map.has_key?(quotas, "max_size"),
         true <- Map.has_key?(quotas, "warning_threshold") do
      true
    else
      _ -> false
    end
  end

  defp validate_root_path(changeset) do
    case get_change(changeset, :root_path) do
      nil -> changeset
      path ->
        if valid_path?(path) do
          changeset
        else
          add_error(changeset, :root_path, "invalid path format")
        end
    end
  end

  defp valid_path?(path) do
    case Path.type(path) do
      :absolute -> true
      _ -> false
    end
  end
end