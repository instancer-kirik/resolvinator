defmodule Resolvinator.Attachments.Attachment do
  use Ecto.Schema
  import Ecto.Changeset

  schema "attachments" do
    field :filename, :string
    field :content_type, :string
    field :size, :integer
    field :path, :string
    field :description, :string
    
    # Polymorphic association fields
    field :attachable_type, :string
    field :attachable_id, :integer
    
    belongs_to :creator, Resolvinator.Accounts.User

    timestamps(type: :utc_datetime)
  end

  def changeset(attachment, attrs) do
    attachment
    |> cast(attrs, [:filename, :content_type, :size, :path, :description, 
                    :attachable_type, :attachable_id, :creator_id])
    |> validate_required([:filename, :content_type, :size, :path, 
                         :attachable_type, :attachable_id, :creator_id])
    |> validate_inclusion(:attachable_type, ["Risk", "Mitigation", "Impact", "MitigationTask"])
  end   
end
