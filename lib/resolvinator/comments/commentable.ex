defmodule Resolvinator.Comments.Commentable do
  @moduledoc """
  Behavior for entities that can receive comments
  """

  defmacro __using__(_opts) do
    quote do
      # Add has_many relationship for comments
      has_many :comments, Resolvinator.Comments.Comment,
        foreign_key: :commentable_id,
        where: [commentable_type: to_string(__MODULE__)]

      # Optional: Add comment-related functions to the schema
      def add_comment(struct, attrs) do
        Ecto.build_assoc(struct, :comments, Map.merge(attrs, %{
          commentable_type: to_string(__MODULE__)
        }))
      end

      def comment_count(struct) do
        struct
        |> Ecto.assoc(:comments)
        |> Resolvinator.Repo.aggregate(:count)
      end
    end
  end
end
