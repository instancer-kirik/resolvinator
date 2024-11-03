defmodule Resolvinator.DocumentsTest do
  use Resolvinator.DataCase

  alias Resolvinator.Documents

  describe "documents" do
    alias Resolvinator.Documents.Document

    import Resolvinator.DocumentsFixtures

    @invalid_attrs %{size: nil, status: nil, description: nil, title: nil, file_path: nil, content_type: nil}

    test "list_documents/0 returns all documents" do
      document = document_fixture()
      assert Documents.list_documents() == [document]
    end

    test "get_document!/1 returns the document with given id" do
      document = document_fixture()
      assert Documents.get_document!(document.id) == document
    end

    test "create_document/1 with valid data creates a document" do
      valid_attrs = %{size: 42, status: "some status", description: "some description", title: "some title", file_path: "some file_path", content_type: "some content_type"}

      assert {:ok, %Document{} = document} = Documents.create_document(valid_attrs)
      assert document.size == 42
      assert document.status == "some status"
      assert document.description == "some description"
      assert document.title == "some title"
      assert document.file_path == "some file_path"
      assert document.content_type == "some content_type"
    end

    test "create_document/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Documents.create_document(@invalid_attrs)
    end

    test "update_document/2 with valid data updates the document" do
      document = document_fixture()
      update_attrs = %{size: 43, status: "some updated status", description: "some updated description", title: "some updated title", file_path: "some updated file_path", content_type: "some updated content_type"}

      assert {:ok, %Document{} = document} = Documents.update_document(document, update_attrs)
      assert document.size == 43
      assert document.status == "some updated status"
      assert document.description == "some updated description"
      assert document.title == "some updated title"
      assert document.file_path == "some updated file_path"
      assert document.content_type == "some updated content_type"
    end

    test "update_document/2 with invalid data returns error changeset" do
      document = document_fixture()
      assert {:error, %Ecto.Changeset{}} = Documents.update_document(document, @invalid_attrs)
      assert document == Documents.get_document!(document.id)
    end

    test "delete_document/1 deletes the document" do
      document = document_fixture()
      assert {:ok, %Document{}} = Documents.delete_document(document)
      assert_raise Ecto.NoResultsError, fn -> Documents.get_document!(document.id) end
    end

    test "change_document/1 returns a document changeset" do
      document = document_fixture()
      assert %Ecto.Changeset{} = Documents.change_document(document)
    end
  end
end
