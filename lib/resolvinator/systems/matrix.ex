defmodule Resolvinator.Systems.Matrix do
  @moduledoc """
  Systems Matrix Schema - A comprehensive framework for describing and analyzing systems
  across multiple dimensions and aspects.

  The matrix consists of:
  - Fundamental aspects (structural characteristics)
  - Values (goals and motivations)
  - Measures (performance criteria)
  - Control mechanisms
  - Interface relationships
  - Future plans
  - Purpose definitions
  
  Each aspect is analyzed across different enablers (human, physical, information)
  and system components (input, output, process, environment).
  """
  use Resolvinator.Schema
  import Ecto.Changeset

  @dimensions ~w(fundamental values measures control interface future purpose)a
  @components ~w(input output process environment human_enabler physical_enabler information_enabler)a
  @statuses ~w(draft active archived deprecated)a

  def dimensions, do: @dimensions
  def components, do: @components
  def statuses, do: @statuses

  defmodule MatrixComponent do
    @moduledoc """
    Represents a single cell in the systems matrix.
    Each cell can have a primary value, metadata, and attachments.
    """
    use Ecto.Schema
    import Ecto.Changeset
    @derive {Jason.Encoder, only: [:value, :metadata, :attachments, :status, :priority, :tags, :last_updated, :version]}

    @primary_key false
    embedded_schema do
      field :value, :string
      field :metadata, :map, default: %{}
      field :attachments, {:array, :string}, default: []
      field :status, :string
      field :priority, :integer, default: 0
      field :tags, {:array, :string}, default: []
      field :version, :string
      field :last_updated, :utc_datetime_usec
      field :dependencies, {:array, :string}, default: []
      field :constraints, :map, default: %{}
      field :validation_rules, :map, default: %{}
      field :source, :string
      field :confidence_level, :float
    end

    def changeset(component, attrs) do
      component
      |> cast(attrs, [:value, :metadata, :attachments, :status, :priority, :tags, 
                     :version, :dependencies, :constraints, :validation_rules, 
                     :source, :confidence_level])
      |> validate_metadata()
      |> validate_priority()
      |> validate_confidence_level()
      |> put_last_updated()
    end

    defp validate_metadata(changeset) do
      case get_change(changeset, :metadata) do
        nil -> changeset
        metadata when not is_map(metadata) ->
          add_error(changeset, :metadata, "must be a map")
        _ -> changeset
      end
    end

    defp validate_priority(changeset) do
      case get_change(changeset, :priority) do
        nil -> changeset
        priority when not is_integer(priority) or priority < 0 or priority > 100 ->
          add_error(changeset, :priority, "must be an integer between 0 and 100")
        _ -> changeset
      end
    end

    defp validate_confidence_level(changeset) do
      case get_change(changeset, :confidence_level) do
        nil -> changeset
        level when not is_float(level) or level < 0.0 or level > 1.0 ->
          add_error(changeset, :confidence_level, "must be a float between 0.0 and 1.0")
        _ -> changeset
      end
    end

    defp put_last_updated(changeset) do
      if Ecto.Changeset.changed?(changeset) do
        put_change(changeset, :last_updated, DateTime.utc_now())
      else
        changeset
      end
    end
  end

  defmodule MatrixRow do
    @moduledoc """
    Represents a row in the systems matrix, containing components for
    input, output, process, environment, and various enablers.
    """
    use Ecto.Schema
    import Ecto.Changeset
    @derive {Jason.Encoder, only: [:input, :output, :process, :environment, 
                                 :human_enabler, :physical_enabler, :information_enabler,
                                 :summary, :metadata, :status, :version, :tags]}

    @primary_key false
    embedded_schema do
      embeds_one :input, MatrixComponent, on_replace: :update
      embeds_one :output, MatrixComponent, on_replace: :update
      embeds_one :process, MatrixComponent, on_replace: :update
      embeds_one :environment, MatrixComponent, on_replace: :update
      embeds_one :human_enabler, MatrixComponent, on_replace: :update
      embeds_one :physical_enabler, MatrixComponent, on_replace: :update
      embeds_one :information_enabler, MatrixComponent, on_replace: :update
      
      field :summary, :string
      field :metadata, :map, default: %{}
      field :status, :string
      field :version, :string
      field :tags, {:array, :string}, default: []
      field :last_updated, :utc_datetime_usec
      field :completeness_score, :float
      field :review_status, :string
    end

    def changeset(row, attrs) do
      row
      |> cast(attrs, [:summary, :metadata, :status, :version, :tags, 
                     :completeness_score, :review_status])
      |> cast_embed(:input)
      |> cast_embed(:output)
      |> cast_embed(:process)
      |> cast_embed(:environment)
      |> cast_embed(:human_enabler)
      |> cast_embed(:physical_enabler)
      |> cast_embed(:information_enabler)
      |> validate_metadata()
      |> validate_completeness_score()
      |> put_last_updated()
    end

    defp validate_metadata(changeset) do
      case get_change(changeset, :metadata) do
        nil -> changeset
        metadata when not is_map(metadata) ->
          add_error(changeset, :metadata, "must be a map")
        _ -> changeset
      end
    end

    defp validate_completeness_score(changeset) do
      case get_change(changeset, :completeness_score) do
        nil -> changeset
        score when not is_float(score) or score < 0.0 or score > 1.0 ->
          add_error(changeset, :completeness_score, "must be a float between 0.0 and 1.0")
        _ -> changeset
      end
    end

    defp put_last_updated(changeset) do
      if Ecto.Changeset.changed?(changeset) do
        put_change(changeset, :last_updated, DateTime.utc_now())
      else
        changeset
      end
    end
  end

  @derive {Jason.Encoder, only: [:name, :description, :fundamental, :values, :measures, 
                               :control, :interface, :future, :purpose, :version, 
                               :status, :metadata, :tags, :maturity_level]}
  schema "system_matrices" do
    field :name, :string
    field :description, :string
    
    # Matrix dimensions as embedded schemas
    embeds_one :fundamental, MatrixRow, on_replace: :update
    embeds_one :values, MatrixRow, on_replace: :update
    embeds_one :measures, MatrixRow, on_replace: :update
    embeds_one :control, MatrixRow, on_replace: :update
    embeds_one :interface, MatrixRow, on_replace: :update
    embeds_one :future, MatrixRow, on_replace: :update
    embeds_one :purpose, MatrixRow, on_replace: :update

    # Metadata
    field :version, :string
    field :status, :string
    field :metadata, :map, default: %{}
    field :tags, {:array, :string}, default: []
    field :maturity_level, :integer
    field :review_cycle, :string
    field :last_review_date, :utc_datetime_usec
    field :next_review_date, :utc_datetime_usec
    field :review_history, {:array, :map}, default: []
    field :compliance_status, :map, default: %{}
    field :external_references, {:array, :map}, default: []

    # Relationships
    belongs_to :system, Resolvinator.Systems.System
    belongs_to :created_by, Resolvinator.Acts.User
    belongs_to :updated_by, Resolvinator.Acts.User
    belongs_to :parent_matrix, Resolvinator.Systems.Matrix
    has_many :child_matrices, Resolvinator.Systems.Matrix, foreign_key: :parent_matrix_id

    timestamps()
  end

  def changeset(matrix, attrs) do
    matrix
    |> cast(attrs, [:name, :description, :version, :status, :metadata, :tags,
                   :maturity_level, :review_cycle, :last_review_date, :next_review_date,
                   :review_history, :compliance_status, :external_references])
    |> cast_embed(:fundamental)
    |> cast_embed(:values)
    |> cast_embed(:measures)
    |> cast_embed(:control)
    |> cast_embed(:interface)
    |> cast_embed(:future)
    |> cast_embed(:purpose)
    |> validate_required([:name, :status])
    |> validate_metadata()
    |> validate_inclusion(:status, @statuses)
    |> validate_maturity_level()
  end

  defp validate_metadata(changeset) do
    case get_change(changeset, :metadata) do
      nil -> changeset
      metadata when not is_map(metadata) ->
        add_error(changeset, :metadata, "must be a map")
      _ -> changeset
    end
  end

  defp validate_maturity_level(changeset) do
    case get_change(changeset, :maturity_level) do
      nil -> changeset
      level when not is_integer(level) or level < 1 or level > 5 ->
        add_error(changeset, :maturity_level, "must be an integer between 1 and 5")
      _ -> changeset
    end
  end

  @doc """
  Creates a blank matrix with default values.
  """
  def new(attrs \\ %{}) do
    %__MODULE__{}
    |> changeset(attrs)
  end

  @doc """
  Gets a specific cell value from the matrix.
  """
  def get_cell(matrix, dimension, component) when dimension in @dimensions and component in @components do
    case Map.get(matrix, dimension) do
      nil -> nil
      row -> Map.get(row, component)
    end
  end

  @doc """
  Updates a specific cell in the matrix.
  """
  def update_cell(matrix, dimension, component, value) when dimension in @dimensions and component in @components do
    row = Map.get(matrix, dimension) || %MatrixRow{}
    updated_row = Map.put(row, component, value)
    Map.put(matrix, dimension, updated_row)
  end

  @doc """
  Serializes the matrix to JSON.
  """
  def to_json(matrix) do
    Jason.encode!(matrix)
  end

  @doc """
  Deserializes the matrix from JSON.
  """
  def from_json(json) do
    with {:ok, data} <- Jason.decode(json),
         {:ok, matrix} <- __MODULE__.new(data) do
      {:ok, matrix}
    else
      error -> {:error, error}
    end
  end

  @doc """
  Exports the matrix to CSV format.
  Returns a list of CSV rows.
  """
  def to_csv(matrix) do
    headers = ["Dimension", "Component", "Value", "Status", "Priority", "Tags"]
    
    rows = for dimension <- @dimensions,
              component <- @components do
      cell = get_cell(matrix, dimension, component)
      [
        Atom.to_string(dimension),
        Atom.to_string(component),
        cell.value || "",
        cell.status || "",
        to_string(cell.priority || 0),
        Enum.join(cell.tags || [], ";")
      ]
    end

    [headers | rows]
  end

  @doc """
  Creates a migration for the system_matrices table.
  """
  def create_migration do
    """
    defmodule Resolvinator.Repo.Migrations.CreateSystemMatrices do
      use Ecto.Migration

      def change do
        create table(:system_matrices) do
          add :name, :string, null: false
          add :description, :text
          add :fundamental, :map
          add :values, :map
          add :measures, :map
          add :control, :map
          add :interface, :map
          add :future, :map
          add :purpose, :map
          add :version, :string
          add :status, :string
          add :metadata, :map
          add :tags, {:array, :string}
          add :maturity_level, :integer
          add :review_cycle, :string
          add :last_review_date, :utc_datetime_usec
          add :next_review_date, :utc_datetime_usec
          add :review_history, {:array, :map}
          add :compliance_status, :map
          add :external_references, {:array, :map}
          
          add :system_id, references(:systems, type: :binary_id)
          add :created_by_id, references(:users, type: :binary_id)
          add :updated_by_id, references(:users, type: :binary_id)
          add :parent_matrix_id, references(:system_matrices, type: :binary_id)

          timestamps()
        end

        create index(:system_matrices, [:system_id])
        create index(:system_matrices, [:created_by_id])
        create index(:system_matrices, [:updated_by_id])
        create index(:system_matrices, [:parent_matrix_id])
      end
    end
    """
  end
end
