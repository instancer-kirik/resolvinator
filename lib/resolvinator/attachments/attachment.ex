defmodule Resolvinator.Attachments.Attachment do
  use Flint.Schema
  use Resolvinator.Attachments.AttachmentBehavior,
    type_name: :attachment,
    table_name: "attachments"

  def changeset(attachment, attrs) do
    attachment
    |> base_changeset(attrs)
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
end
