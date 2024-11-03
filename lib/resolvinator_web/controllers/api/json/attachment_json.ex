defmodule ResolvinatorWeb.API.AttachmentJSON do
  import ResolvinatorWeb.API.JSONHelpers
  alias ResolvinatorWeb.API.UserJSON

  def data(attachment, opts \\ []) do
    includes = Keyword.get(opts, :includes, [])

    base = %{
      id: attachment.id,
      type: "attachment",
      attributes: %{
        filename: attachment.filename,
        content_type: attachment.content_type,
        size: attachment.size,
        description: attachment.description,
        metadata: attachment.metadata,
        attachable_type: attachment.attachable_type,
        attachable_id: attachment.attachable_id,
        inserted_at: attachment.inserted_at,
        updated_at: attachment.updated_at
      },
      relationships: %{}
    }

    relationships = %{}
    |> maybe_add_relationship("creator", attachment.creator, &UserJSON.reference_data/1, includes)

    Map.put(base, :relationships, relationships)
  end

  def reference_data(attachment) do
    %{
      id: attachment.id,
      type: "attachment",
      attributes: %{
        filename: attachment.filename,
        content_type: attachment.content_type
      }
    }
  end
end
