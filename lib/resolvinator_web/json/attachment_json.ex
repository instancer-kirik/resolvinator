defmodule ResolvinatorWeb.AttachmentJSON do
  import ResolvinatorWeb.JSONHelpers

  def data(attachment, opts \\ []) do
    includes = parse_includes(opts[:includes] || [])
    
    base = %{
      id: attachment.id,
      type: "attachment",
      attributes: %{
        filename: attachment.filename,
        content_type: attachment.content_type,
        size: attachment.size,
        description: attachment.description,
        attachable_type: attachment.attachable_type,
        attachable_id: attachment.attachable_id,
        inserted_at: attachment.inserted_at,
        updated_at: attachment.updated_at
      },
      relationships: %{}
    }

    relationships = %{}
    |> maybe_add_relationship("creator", attachment.creator, &user_data/1, includes)

    Map.put(base, :relationships, relationships)
  end
end 