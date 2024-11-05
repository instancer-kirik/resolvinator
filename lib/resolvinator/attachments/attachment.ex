defmodule Resolvinator.Attachments.Attachment do
  use Flint.Schema
  use Resolvinator.Attachments.AttachmentBehavior,
    type_name: :attachment,
    table_name: "attachments"

  schema_field do
    # Math-specific fields
    field :math_related, :boolean, default: false
    field :visualization_type, :string
    embeds_one :math_image, Resolvinator.Attachments.MathImage
  end

  def changeset(attachment, attrs) do
    attachment
    |> base_changeset(attrs)
    |> cast(attrs, [:math_related, :visualization_type])
    |> cast_embed(:math_image)
    |> validate_math_image()
  end

  def storage_path do
    Application.get_env(:resolvinator, :upload_path, "priv/static/uploads")
  end

  def generate_filename(original_filename) do
    ext = Path.extname(original_filename)
    "#{Ecto.UUID.generate()}#{ext}"
  end

  def file_path(filename) do
    Path.join(storage_path(), filename)
  end

  # Image processing for math visualizations
  def process_math_image(path, opts \\ []) do
    case Mogrify.open(path) do
      %Mogrify.Image{} = image ->
        image
        |> maybe_add_grid(opts[:grid_enabled])
        |> maybe_add_annotations(opts[:annotations])
        |> maybe_add_labels(opts[:labels])
        |> Mogrify.save(in_place: true)
        {:ok, path}
      error ->
        {:error, "Failed to process image: #{inspect(error)}"}
    end
  end

  defp validate_math_image(changeset) do
    if get_change(changeset, :math_related) do
      validate_required(changeset, [:visualization_type])
    else
      changeset
    end
  end

  defp maybe_add_grid(image, true) do
    Mogrify.custom(image, "draw", "grid 50x50+0+0")
  end
  defp maybe_add_grid(image, _), do: image

  defp maybe_add_annotations(image, annotations) when is_list(annotations) do
    Enum.reduce(annotations, image, fn annotation, acc ->
      add_annotation(acc, annotation)
    end)
  end
  defp maybe_add_annotations(image, _), do: image

  defp add_annotation(image, %{type: "arrow", from: {x1, y1}, to: {x2, y2}}) do
    Mogrify.custom(image, "draw", "line #{x1},#{y1} #{x2},#{y2}")
  end
  defp add_annotation(image, %{type: "circle", center: {x, y}, radius: r}) do
    Mogrify.custom(image, "draw", "circle #{x},#{y} #{x+r},#{y}")
  end
  # Add more annotation types as needed
end
