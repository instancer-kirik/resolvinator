defmodule Resolvinator.Attachments.MathImage do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key false
  embedded_schema do
    field :image_type, :string  # diagram, plot, geometric_proof, graph
    field :annotations, {:array, :map}
    field :coordinates, {:array, :map}
    field :labels, {:array, :map}
    field :scale, :float
    field :grid_enabled, :boolean, default: false
    field :axis_labels, :map
  end

  def changeset(math_image, attrs) do
    math_image
    |> cast(attrs, [:image_type, :annotations, :coordinates, :labels, :scale, :grid_enabled, :axis_labels])
    |> validate_inclusion(:image_type, ~w(diagram plot geometric_proof graph))
    |> validate_coordinates()
    |> validate_annotations()
  end

  defp validate_coordinates(changeset) do
    case get_change(changeset, :coordinates) do
      nil -> changeset
      coordinates when is_list(coordinates) ->
        if Enum.all?(coordinates, &valid_coordinate?/1) do
          changeset
        else
          add_error(changeset, :coordinates, "contains invalid coordinate format")
        end
      _ ->
        add_error(changeset, :coordinates, "must be a list of coordinates")
    end
  end

  defp validate_annotations(changeset) do
    case get_change(changeset, :annotations) do
      nil -> changeset
      annotations when is_list(annotations) ->
        if Enum.all?(annotations, &valid_annotation?/1) do
          changeset
        else
          add_error(changeset, :annotations, "contains invalid annotation format")
        end
      _ ->
        add_error(changeset, :annotations, "must be a list of annotations")
    end
  end

  defp valid_coordinate?(%{"x" => x, "y" => y}) when is_number(x) and is_number(y), do: true
  defp valid_coordinate?(_), do: false

  defp valid_annotation?(%{"type" => type, "data" => data}) when is_map(data) do
    type in ["arrow", "circle", "text", "line"]
  end
  defp valid_annotation?(_), do: false
end
