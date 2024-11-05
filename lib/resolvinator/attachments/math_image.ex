defmodule Resolvinator.Attachments.MathImage do
  use Ecto.Schema

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
end
