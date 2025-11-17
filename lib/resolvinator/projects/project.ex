defmodule Resolvinator.Projects.Project do
  use Ecto.Schema
  import Ecto.Changeset
  alias Resolvinator.Projects.{NestedTerm, ProjectType}
  alias Acts.User

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  @status_values ~w(planning active on_hold completed archived)
  @risk_appetite_values ~w(averse minimal cautious flexible aggressive)

  schema "projects" do
    field :name, :string
    field :description, :string
    field :status, :string, default: "planning"
    field :project_type, :string
    field :risk_appetite, :string
    field :start_date, :date
    field :target_date, :date
    field :completion_date, :date

    # Project-specific settings
    field :settings, :map, default: %{
      # Project metadata
      "metadata" => %{
        "domain" => nil,
        "target_audience" => nil,
        "version" => "0.1.0",
        "license" => nil,
        "repository_url" => nil,
        "documentation_url" => nil,
        "issue_tracker_url" => nil,
        "keywords" => [],
        "categories" => [],
        "visibility" => "private",
        "language" => nil,
        "framework" => nil,
        "dependencies" => %{},
        "dev_dependencies" => %{},
        "contributors" => [],
        "maintainers" => []
      },

      # Development environment
      "development" => %{
        "build_command" => nil,
        "run_command" => nil,
        "test_command" => nil,
        "lint_command" => nil,
        "registered_scripts" => [],
        "file_extensions" => [".py", ".json", ".yml"],
        "excluded_dirs" => ["__pycache__", ".git", "venv"],
        "environment_variables" => %{},
        "required_tools" => [],
        "optional_tools" => []
      },

      # Project structure
      "structure" => %{
        "root_dir" => nil,
        "source_dir" => nil,
        "test_dir" => nil,
        "docs_dir" => nil,
        "build_dir" => nil,
        "assets_dir" => nil,
        "config_dir" => nil
      },

      # Project configuration
      "config" => %{
        "build" => %{
          "target_platforms" => [],
          "optimization_level" => "default",
          "debug_symbols" => true,
          "static_analysis" => true
        },
        "test" => %{
          "frameworks" => [],
          "coverage_threshold" => 80,
          "parallel_execution" => true
        },
        "deployment" => %{
          "strategy" => "manual",
          "environments" => [],
          "required_approvals" => 1
        }
      }
    }

    # Nested terms support
    has_many :nested_terms, NestedTerm
    has_many :root_terms, NestedTerm, where: [parent_id: nil]

    belongs_to :creator, User, type: :binary_id

    timestamps()
  end

  @required_fields ~w(name project_type creator_id)a
  @optional_fields ~w(description status risk_appetite start_date target_date completion_date settings)a

  @doc false
  def changeset(project, attrs) do
    project
    |> cast(attrs, @required_fields ++ @optional_fields)
    |> validate_required(@required_fields)
    |> validate_inclusion(:status, @status_values)
    |> validate_inclusion(:risk_appetite, @risk_appetite_values)
    |> validate_project_type()
    |> validate_dates()
    |> validate_settings()
  end

  @doc """
  Gets a nested term value at the specified path.
  """
  def get_nested_term(project, path) when is_list(path) do
    Enum.find(project.nested_terms, fn term ->
      term.path == Enum.slice(path, 0..-2//-1) and term.key == List.last(path)
    end)
  end

  @doc """
  Sets a nested term value at the specified path.
  """
  def put_nested_term(project, path, value) when is_list(path) do
    attrs = %{
      key: List.last(path),
      path: Enum.slice(path, 0..-2//-1),
      value: value,
      project_id: project.id
    }

    case get_nested_term(project, path) do
      nil ->
        %NestedTerm{} |> NestedTerm.changeset(attrs)
      existing ->
        existing |> NestedTerm.changeset(attrs)
    end
  end

  # Private functions

  defp validate_project_type(changeset) do
    project_type = get_field(changeset, :project_type)

    if project_type && ProjectType.valid_type?(project_type) do
      changeset
    else
      add_error(changeset, :project_type, "is not a valid project type")
    end
  end

  defp validate_dates(changeset) do
    start_date = get_field(changeset, :start_date)
    target_date = get_field(changeset, :target_date)
    completion_date = get_field(changeset, :completion_date)

    changeset
    |> validate_date_order(:start_date, :target_date, start_date, target_date)
    |> validate_date_order(:start_date, :completion_date, start_date, completion_date)
    |> validate_date_order(:target_date, :completion_date, target_date, completion_date)
  end

  defp validate_date_order(changeset, field1, field2, date1, date2) do
    if date1 && date2 && Date.compare(date1, date2) == :gt do
      add_error(changeset, field2, "cannot be before #{field1}")
    else
      changeset
    end
  end

  defp validate_settings(changeset) do
    settings = get_field(changeset, :settings)

    if valid_settings?(settings) do
      changeset
    else
      add_error(changeset, :settings, "has invalid structure")
    end
  end

  defp valid_settings?(settings) when is_map(settings) do
    required_keys = ~w(metadata development structure config)
    Enum.all?(required_keys, &Map.has_key?(settings, &1))
  end

  defp valid_settings?(_settings), do: false
end
