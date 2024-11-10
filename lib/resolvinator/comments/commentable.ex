defmodule Resolvinator.Comments.Commentable do
  @moduledoc """
  Behavior for entities that can receive comments
  """

  defmacro __using__(_opts) do
    quote do
      # Remove schema definitions from here since they're now in ContentBehavior
      def add_comment(content, comment_attrs) do
        Ecto.build_assoc(content, :comments, comment_attrs)
      end

      def list_comments(content) do
        Ecto.assoc(content, :comments)
      end
    end
  end
end
