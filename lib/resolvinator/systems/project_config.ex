defmodule Resolvinator.Systems.ProjectConfig do
  use Resolvinator.Schema
  import Ecto.Changeset
  alias Resolvinator.Systems.{System, ProjectConfig}
  alias VES.Accounts.User

  schema "project_configs" do
    belongs_to :system, System
    belongs_to :creator, User

    # Development Environment
    field :environment_type, :string, default: "development"
    field :virtual_env_path, :string
    field :workspace_path, :string
    field :file_extensions, {:array, :string}, default: [".ex", ".exs", ".eex"]
    field :excluded_dirs, {:array, :string}, default: ["_build", "deps", ".git"]
    field :required_tools, {:array, :string}, default: []
    field :tool_versions, :map, default: %{}

    # Development Standards
    field :code_style, :map, default: %{
      "style_guide" => "elixir_style",
      "max_complexity" => 10,
      "formatters" => ["mix format"],
      "linters" => ["credo"]
    }

    field :testing, :map, default: %{
      "framework" => "exunit",
      "coverage_target" => 80,
      "strategies" => ["unit", "integration"],
      "performance_benchmarks" => %{}
    }

    field :documentation, :map, default: %{
      "required_sections" => ["API", "Setup", "Usage"],
      "format" => "markdown",
      "tools" => ["ex_doc"]
    }

    field :security, :map, default: %{
      "requirements" => [],
      "scan_frequency" => "weekly",
      "vulnerability_threshold" => "high"
    }

    # Project Commands
    field :commands, :map, default: %{
      "build" => "mix compile",
      "run" => "mix run",
      "test" => "mix test",
      "lint" => "mix credo",
      "deploy" => nil
    }

    # Project Resources
    field :resources, :map, default: %{}
    field :metadata, :map, default: %{}

    timestamps()
  end

  def changeset(%ProjectConfig{} = config, attrs) do
    config
    |> cast(attrs, [
      :system_id,
      :creator_id,
      :environment_type,
      :virtual_env_path,
      :workspace_path,
      :file_extensions,
      :excluded_dirs,
      :required_tools,
      :tool_versions,
      :code_style,
      :testing,
      :documentation,
      :security,
      :commands,
      :resources,
      :metadata
    ])
    |> validate_required([:system_id, :creator_id])
    |> foreign_key_constraint(:system_id)
    |> foreign_key_constraint(:creator_id)
    |> validate_inclusion(:environment_type, ["development", "staging", "production"])
    |> validate_code_style()
    |> validate_testing()
    |> validate_documentation()
    |> validate_security()
  end

  defp validate_code_style(changeset) do
    case get_change(changeset, :code_style) do
      nil -> changeset
      style ->
        if is_map(style) and
           is_binary(style["style_guide"]) and
           is_integer(style["max_complexity"]) and
           is_list(style["formatters"]) and
           is_list(style["linters"]) do
          changeset
        else
          add_error(changeset, :code_style, "invalid code style configuration")
        end
    end
  end

  defp validate_testing(changeset) do
    case get_change(changeset, :testing) do
      nil -> changeset
      testing ->
        if is_map(testing) and
           is_binary(testing["framework"]) and
           is_integer(testing["coverage_target"]) and
           is_list(testing["strategies"]) and
           is_map(testing["performance_benchmarks"]) do
          changeset
        else
          add_error(changeset, :testing, "invalid testing configuration")
        end
    end
  end

  defp validate_documentation(changeset) do
    case get_change(changeset, :documentation) do
      nil -> changeset
      docs ->
        if is_map(docs) and
           is_list(docs["required_sections"]) and
           is_binary(docs["format"]) and
           is_list(docs["tools"]) do
          changeset
        else
          add_error(changeset, :documentation, "invalid documentation configuration")
        end
    end
  end

  defp validate_security(changeset) do
    case get_change(changeset, :security) do
      nil -> changeset
      security ->
        if is_map(security) and
           is_list(security["requirements"]) and
           is_binary(security["scan_frequency"]) and
           is_binary(security["vulnerability_threshold"]) do
          changeset
        else
          add_error(changeset, :security, "invalid security configuration")
        end
    end
  end
end
