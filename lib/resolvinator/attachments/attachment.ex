defmodule Resolvinator.Attachments.Attachment do
  use Ecto.Schema
  import Ecto.Changeset
  use Flint.Schema

  schema "attachments" do
    # Base fields
    field :filename, :string
    field :content_type, :string
    field :size, :integer
    field :path, :string
    field :description, :string
    field :metadata, :map, default: %{}

    # Polymorphic association fields
    field :attachable_type, :string
    field :attachable_id, :integer

    belongs_to :creator, VES.Accounts.User

    # Math-specific fields
    field :math_related, :boolean, default: false
    field :visualization_type, :string
    embeds_one :math_image, Resolvinator.Attachments.MathImage

    timestamps(type: :utc_datetime)
  end

  def changeset(attachment, attrs) do
    attachment
    |> cast(attrs, [
      :filename, :content_type, :size, :path, :description,
      :attachable_type, :attachable_id, :creator_id, :metadata,
      :math_related, :visualization_type
    ])
    |> validate_required([
      :filename, :content_type, :size, :path,
      :attachable_type, :attachable_id, :creator_id
    ])
    |> validate_inclusion(:attachable_type, ~w(Risk Mitigation Impact MitigationTask))
    |> foreign_key_constraint(:creator_id)
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
    try do
      image = Mogrify.open(path)
      processed_image =
        image
        |> maybe_add_grid(opts[:grid_enabled])
        |> maybe_add_annotations(opts[:annotations])
        |> maybe_add_labels(opts[:labels])
        |> Mogrify.save(in_place: true)

      {:ok, processed_image.path}
    rescue
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

  defp maybe_add_labels(image, labels) when is_list(labels) do
    Enum.reduce(labels, image, fn %{text: text, position: {x, y}}, acc ->
      Mogrify.custom(acc, "draw", "text #{x},#{y} '#{text}'")
    end)
  end
  defp maybe_add_labels(image, _), do: image

  defp add_annotation(image, %{type: "arrow", from: {x1, y1}, to: {x2, y2}}) do
    Mogrify.custom(image, "draw", "line #{x1},#{y1} #{x2},#{y2}")
  end
  defp add_annotation(image, %{type: "circle", center: {x, y}, radius: r}) do
    Mogrify.custom(image, "draw", "circle #{x},#{y} #{x+r},#{y}")
  end
  # Add more annotation types as needed
end
