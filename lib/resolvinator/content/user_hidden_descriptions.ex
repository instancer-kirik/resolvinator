defmodule Resolvinator.Content.UserHiddenDescription do
  use Ecto.Schema
  import Ecto.Changeset

  schema "user_hidden_descriptions" do
    belongs_to :user, Resolvinator.Accounts.User
    belongs_to :description, Resolvinator.Content.Description

    timestamps()
  end

  @doc false
  def changeset(user_hidden_description, attrs) do
    user_hidden_description
    |> cast(attrs, [:user_id, :description_id])
    |> validate_required([:user_id, :description_id])
  end
end
