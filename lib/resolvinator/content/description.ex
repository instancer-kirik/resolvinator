defmodule Resolvinator.Content.Description do
  use Ecto.Schema
  import Ecto.Changeset

  schema "descriptions" do
    field :text, :string
    field :descriptionable_id, :integer
    field :descriptionable_type, :string

    timestamps()
  end

  @doc false
  def changeset(description, attrs) do
    description
    |> cast(attrs, [:text, :descriptionable_id, :descriptionable_type])
    |> validate_required([:text, :descriptionable_id, :descriptionable_type])
  end
end
