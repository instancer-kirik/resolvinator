defmodule Resolvinator.Messages.Message do
  use Ecto.Schema
  import Ecto.Changeset

  schema "messages" do
    field :content, :string
    field :from_user_id, :integer
    field :to_user_id, :integer
    field :read, :boolean, default: false

    timestamps()
  end

  def changeset(message, attrs) do
    message
    |> cast(attrs, [:content, :from_user_id, :to_user_id])
    |> validate_required([:content, :from_user_id, :to_user_id])
  end
end 