defmodule Resolvinator.Documents.Document do
  use Ecto.Schema
  import Ecto.Changeset

  schema "documents" do
    field :size, :integer
    field :status, :string
    field :description, :string
    field :title, :string
    field :file_path, :string
    field :content_type, :string
    field :creator_id, :id

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(document, attrs) do
    document
    |> cast(attrs, [:title, :description, :file_path, :content_type, :size, :status])
    |> validate_required([:title, :description, :file_path, :content_type, :size, :status])
  end
end
