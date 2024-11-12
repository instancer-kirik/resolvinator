defmodule Resolvinator.Content.TopicRelationship do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "topic_relationships" do
    field :relationship_type, :string, default: "related"
    field :metadata, :map, default: %{}

    belongs_to :topic, Resolvinator.Content.Topic
    belongs_to :related_topic, Resolvinator.Content.Topic

    timestamps(type: :utc_datetime)
  end

  def changeset(relationship, attrs) do
    relationship
    |> cast(attrs, [:topic_id, :related_topic_id, :relationship_type, :metadata])
    |> validate_required([:topic_id, :related_topic_id, :relationship_type])
    |> validate_inclusion(:relationship_type, ~w(related prerequisite successor))
    |> foreign_key_constraint(:topic_id)
    |> foreign_key_constraint(:related_topic_id)
    |> unique_constraint([:topic_id, :related_topic_id])
    |> validate_different_topics()
  end

  defp validate_different_topics(changeset) do
    case {get_field(changeset, :topic_id), get_field(changeset, :related_topic_id)} do
      {id, id} when not is_nil(id) ->
        add_error(changeset, :related_topic_id, "cannot relate a topic to itself")
      _ ->
        changeset
    end
  end 
end
