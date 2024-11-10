defmodule Resolvinator.Content.Gesture do
  use Ecto.Schema
  import Ecto.Changeset

  schema "gestures" do
    field :name, :string
    field :fingers, :string
    field :svg, :string
    
    many_to_many :descriptions, Resolvinator.Content.Description,
      join_through: Resolvinator.Content.GestureDescription,
      on_replace: :delete

    timestamps()
  end

  @doc false
  def changeset(gesture, attrs) do
    gesture
    |> cast(attrs, [:name, :fingers, :svg])
    |> validate_required([:name, :fingers, :svg])
  end
end

defmodule Resolvinator.Content.GestureDescription do
  use Resolvinator.Content.ContentDescription,
    table_name: "gesture_descriptions",
    content_type: :gesture,
    content_module: Resolvinator.Content.Gesture,
    foreign_key: :gesture_id
end
