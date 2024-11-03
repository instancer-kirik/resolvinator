defmodule Resolvinator.DocumentsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Resolvinator.Documents` context.
  """

  @doc """
  Generate a document.
  """
  def document_fixture(attrs \\ %{}) do
    {:ok, document} =
      attrs
      |> Enum.into(%{
        content_type: "some content_type",
        description: "some description",
        file_path: "some file_path",
        size: 42,
        status: "some status",
        title: "some title"
      })
      |> Resolvinator.Documents.create_document()

    document
  end
end
