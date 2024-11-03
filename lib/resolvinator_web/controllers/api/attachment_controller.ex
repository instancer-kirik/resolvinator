defmodule ResolvinatorWeb.API.AttachmentController do
  use ResolvinatorWeb, :controller

  alias Resolvinator.Attachments
  alias Resolvinator.Attachments.Attachment
  alias ResolvinatorWeb.API.AttachmentJSON

  def create(conn, %{"file" => upload_params} = params) do
    with {:ok, filename} <- upload_file(upload_params),
         {:ok, attachment} <- create_attachment(filename, upload_params, params, conn) do
      
      conn
      |> put_status(:created)
      |> json(%{data: AttachmentJSON.data(attachment)})
    else
      {:error, reason} ->
        conn
        |> put_status(:unprocessable_entity)
        |> json(%{error: reason})
    end
  end

  def show(conn, %{"id" => id}) do
    attachment = Attachments.get_attachment!(id)
    send_download(conn, {:file, Attachment.file_path(attachment.path)}, 
      filename: attachment.filename)
  end

  def delete(conn, %{"id" => id}) do
    attachment = Attachments.get_attachment!(id)
    
    with :ok <- File.rm(Attachment.file_path(attachment.path)),
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
    File.mkdir_p!(Attachment.storage_path())
    filename = Attachment.generate_filename(upload.filename)
    path = Attachment.file_path(filename)
    
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
      metadata: params["metadata"] || %{},
      attachable_type: params["attachable_type"],
      attachable_id: params["attachable_id"],
      creator_id: conn.assigns.current_user.id
    }

    Attachments.create_attachment(attachment_params)
  end
end 