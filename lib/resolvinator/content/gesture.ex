defmodule Resolvinator.Content.Gesture do
  use Ecto.Schema
  import Ecto.Changeset

  schema "gestures" do
    field :name, :string
    field :fingers, :string
    field :svg, :string
    has_many :descriptions, Resolvinator.Content.Description

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
  use Ecto.Schema
  import Ecto.Changeset

  schema "gesture_descriptions" do
    belongs_to :gesture, Resolvinator.Content.Gesture
    belongs_to :description, Resolvinator.Content.Description

    timestamps()
  end

  @doc false
  def changeset(gesture_description, attrs) do
    gesture_description
    |> cast(attrs, [:gesture_id, :description_id])
    |> validate_required([:gesture_id, :description_id])
    |> unique_constraint([:gesture_id, :description_id])
  end
end
