defmodule Resolvinator.Comments.Comment do
  use Ecto.Schema
  import Ecto.Changeset
  import Ecto.Query

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "comments" do
    field :content, :string
    field :status, :string, default: "active"
    field :metadata, :map, default: %{}
    field :commentable_type, :string
    field :commentable_id, :binary_id

    belongs_to :parent, __MODULE__
    belongs_to :creator, VES.Accounts.User
    has_many :replies, __MODULE__, foreign_key: :parent_id

    timestamps(type: :utc_datetime)
  end

  def changeset(comment, attrs) do
    comment
    |> cast(attrs, [:content, :status, :metadata, :commentable_type,
                    :commentable_id, :parent_id, :creator_id])
    |> validate_required([:content, :commentable_type, :commentable_id, :creator_id])
    |> validate_inclusion(:status, ~w(active hidden deleted))
    |> foreign_key_constraint(:parent_id)
    |> foreign_key_constraint(:creator_id)
  end

  # Query helpers
  def for_commentable(query \\ __MODULE__, type, id) do
    from c in query,
      where: c.commentable_type == ^to_string(type) and
             c.commentable_id == ^id
  end

  def root_comments(query \\ __MODULE__) do
    from c in query,
      where: is_nil(c.parent_id)
  end

  def with_replies(query \\ __MODULE__) do
    from c in query,
      preload: [replies: ^from(r in __MODULE__, order_by: r.inserted_at)]
  end
end
