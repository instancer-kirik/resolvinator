defmodule ResolvinatorWeb.AttachmentController do
  use ResolvinatorWeb, :controller

  alias Resolvinator.Attachments
  #alias Resolvinator.Attachments.Attachment

  def create(conn, %{"file" => upload_params} = params) do
    # Handle file upload
    with {:ok, filename} <- upload_file(upload_params),
         {:ok, attachment} <- create_attachment(filename, upload_params, params, conn) do
      
      conn
      |> put_status(:created)
      |> json(%{data: attachment_json(attachment)})
    else
      {:error, reason} ->
        conn
        |> put_status(:unprocessable_entity)
        |> json(%{error: reason})
    end
  end

  def show(conn, %{"id" => id}) do
    attachment = Attachments.get_attachment!(id)
    send_download(conn, {:file, attachment.path}, filename: attachment.filename)
  end

  def delete(conn, %{"id" => id}) do
    attachment = Attachments.get_attachment!(id)
    
    with :ok <- File.rm(attachment.path),
         {:ok, _} <- Attachments.delete_attachment(attachment) do
      send_resp(conn, :no_content, "")
    else
      _ ->
        conn
        |> put_status(:unprocessable_entity)
        |> json(%{error: "Could not delete attachment"})
    end
  end

  defp upload_file(%Plug.Upload{} = upload) do
    upload_dir = Application.get_env(:resolvinator, :upload_path, "priv/static/uploads")
    File.mkdir_p!(upload_dir)
    
    ext = Path.extname(upload.filename)
    filename = "#{Ecto.UUID.generate()}#{ext}"
    path = Path.join(upload_dir, filename)
    
    case File.cp(upload.path, path) do
      :ok -> {:ok, filename}
      _ -> {:error, "Failed to save file"}
    end
  end

  defp create_attachment(filename, upload, params, conn) do
    attachment_params = %{
      filename: upload.filename,
      content_type: upload.content_type,
      size: upload.size,
      path: filename,
      description: params["description"],
      attachable_type: params["attachable_type"],
      attachable_id: params["attachable_id"],
      creator_id: conn.assigns.current_user.id
    }

    Attachments.create_attachment(attachment_params)
  end

  defp attachment_json(attachment) do
    %{
      id: attachment.id,
      filename: attachment.filename,
      content_type: attachment.content_type,
      size: attachment.size,
      description: attachment.description,
      attachable_type: attachment.attachable_type,
      attachable_id: attachment.attachable_id,
      inserted_at: attachment.inserted_at
    }
  end
end 