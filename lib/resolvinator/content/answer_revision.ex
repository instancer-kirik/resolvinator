defmodule Resolvinator.Content.AnswerRevision do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "answer_revisions" do
    field :content, :string
    field :version, :integer
    field :change_summary, :string
    
    belongs_to :answer, Resolvinator.Content.Answer
    belongs_to :creator, Resolvinator.Acts.User

    timestamps(type: :utc_datetime)
  end

  def changeset(revision, attrs) do
    revision
    |> cast(attrs, [:content, :version, :change_summary, :answer_id, :creator_id])
    |> validate_required([:content, :version, :answer_id, :creator_id])
    |> foreign_key_constraint(:answer_id)
    |> foreign_key_constraint(:creator_id)
  end 
end
