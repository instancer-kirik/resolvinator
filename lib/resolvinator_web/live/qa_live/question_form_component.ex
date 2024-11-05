defmodule ResolvinatorWeb.QALive.QuestionFormComponent do
  use ResolvinatorWeb, :live_component
  alias Resolvinator.Content
  alias Resolvinator.Attachments
  alias Resolvinator.Comments
  alias Resolvinator.AI.FabricClient
  @impl true
  def update(%{question: question} = assigns, socket) do
    changeset = Content.change_question(question)

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:changeset, changeset)
     |> assign(:ai_suggestions, nil)
     |> assign(:similar_questions, [])
     |> assign(:is_math_question, false)
     |> assign(:show_advanced_options, false)
     |> assign(:attachments, [])
     |> assign(:references, [])
     |> allow_upload(:attachments,
         accept: ~w(.pdf .doc .docx .txt .png .jpg .jpeg),
         max_entries: 5,
         max_file_size: 10_000_000) # 10MB
     |> load_references()}
  end

  @impl true
  def handle_event("toggle-math", _, socket) do
    {:noreply, assign(socket, :is_math_question, !socket.assigns.is_math_question)}
  end

  @impl true
  def handle_event("toggle-advanced", _, socket) do
    {:noreply, assign(socket, :show_advanced_options, !socket.assigns.show_advanced_options)}
  end

  @impl true
  def handle_event("validate", %{"question" => params}, socket) do
    changeset =
      socket.assigns.question
      |> Content.change_question(params)
      |> Map.put(:action, :validate)
      # Get AI suggestions as user types
    if String.length(params["desc"] || "") > 50 do
      send(self(), {:get_ai_suggestions, params["desc"]})
    end
    # Handle file validation
    {valid_entries, invalid_entries} = validate_uploads(socket)

    {:noreply,
     socket
     |> assign(:changeset, changeset)
     |> assign(:valid_entries, valid_entries)
     |> assign(:invalid_entries, invalid_entries)}
  end

  @impl true
  def handle_event("cancel-upload", %{"ref" => ref}, socket) do
    {:noreply, cancel_upload(socket, :attachments, ref)}
  end

  @impl true
  def handle_event("remove-attachment", %{"id" => id}, socket) do
    {:noreply,
     socket
     |> update(:attachments, &Enum.reject(&1, fn a -> a.id == id end))}
  end

  @impl true
  def handle_event("add-reference", %{"ref" => content_id}, socket) do
    case Content.get_content(content_id) do
      nil -> {:noreply, socket}
      content ->
        {:noreply,
         socket
         |> update(:references, &[content | &1])}
    end
  end

  @impl true
  def handle_event("save", %{"question" => params}, socket) do
    save_question(socket, socket.assigns.action, params)
  end

  defp save_question(socket, :new, params) do
    # First save the question
    case Content.create_question(params) do
      {:ok, question} ->
        # Then handle file uploads
        case handle_attachments(socket, question) do
          {:ok, _attachments} ->
            {:noreply,
             socket
             |> put_flash(:info, "Question created successfully")
             |> push_redirect(to: ~p"/qa/#{question}")}

          {:error, reason} ->
            {:noreply,
             socket
             |> put_flash(:error, "Error uploading files: #{reason}")
             |> assign(changeset: Content.change_question(question))}
        end

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end

  defp handle_attachments(socket, question) do
    uploaded_files =
      consume_uploaded_entries(socket, :attachments, fn %{path: path}, entry ->
        filename = entry.client_name
        content_type = entry.client_type

        attachment_params = %{
          filename: filename,
          content_type: content_type,
          size: entry.client_size,
          path: Attachment.generate_filename(filename),
          description: "Uploaded for question #{question.id}",
          attachable_type: "Question",
          attachable_id: question.id,
          creator_id: socket.assigns.current_user.id,
          metadata: %{
            original_filename: filename,
            upload_type: "question_attachment"
          }
        }

        case File.cp(path, Attachment.file_path(attachment_params.path)) do
          :ok -> {:ok, attachment_params}
          {:error, reason} -> {:error, "File copy failed: #{reason}"}
        end
      end)

    case Enum.split_with(uploaded_files, &match?({:ok, _}, &1)) do
      {successful, []} ->
        attachment_params = Enum.map(successful, fn {:ok, params} -> params end)
        Attachments.create_many_attachments(attachment_params)

      {_, failed} ->
        {:error, "Failed to upload files: #{inspect(failed)}"}
    end
  end

  defp load_references(socket) do
    # Load existing references if editing
    references =
      case socket.assigns.question.id do
        nil -> []
        id -> Content.list_references(id)
      end

    assign(socket, :references, references)
  end

  defp validate_uploads(socket) do
    {valid, invalid} =
      Enum.split_with(socket.assigns.uploads.attachments.entries, fn entry ->
        upload_valid?(entry)
      end)
    {valid, invalid}
  end

  defp upload_valid?(entry) do
    case entry.client_type do
      "application/pdf" -> true
      "application/msword" -> true
      "application/vnd.openxmlformats-officedocument.wordprocessingml.document" -> true
      "text/plain" -> true
      "image/png" -> true
      "image/jpeg" -> true
      _ -> false
    end
  end
end
