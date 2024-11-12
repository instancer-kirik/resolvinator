defmodule Resolvinator.Content.ContentTopicRelationship do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "content_topic_relationships" do
    field :content_type, :string
    field :content_id, :binary_id
    field :relationship_type, :string, default: "primary"
    field :metadata, :map, default: %{}

    belongs_to :topic, Resolvinator.Content.Topic

    timestamps(type: :utc_datetime)
  end

  def changeset(relationship, attrs) do
    relationship
    |> cast(attrs, [:topic_id, :content_type, :content_id, :relationship_type, :metadata])
    |> validate_required([:topic_id, :content_type, :content_id, :relationship_type])
    |> validate_inclusion(:relationship_type, ~w(primary secondary related))
    |> validate_inclusion(:content_type, ~w(problem solution advantage lesson))
    |> foreign_key_constraint(:topic_id)
    |> unique_constraint([:topic_id, :content_type, :content_id, :relationship_type])
  end 
end
