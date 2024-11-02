defmodule Resolvinator.Content.ContentBehavior do
  @moduledoc """
  Common behavior for content types (Problem, Solution, Lesson, Advantage)
  """
  
  defmacro __using__(opts) do
    additional_schema = opts[:additional_schema] || quote do end

    quote do
      use Ecto.Schema
      import Ecto.Changeset
      import Ecto.Query
      
      @status_values ~w(initial pending approved rejected)
      @type_name unquote(opts[:type_name] || raise "type_name is required")

      schema unquote(opts[:table_name] || raise "table_name is required") do
        field :name, :string
        field :desc, :string
        field :upvotes, :integer, default: 0
        field :downvotes, :integer, default: 0
        field :status, :string, default: "initial"
        field :rejection_reason, :string
        field :visibility, :string, default: "public"
        field :metadata, :map, default: %{}

        # Creator relationship
        belongs_to :creator, Resolvinator.Accounts.User, foreign_key: :creator_id

        # Self-referential relationships
        many_to_many :related_content, __MODULE__,
          join_through: unquote(opts[:relationship_table]),
          join_keys: unquote(opts[:relationship_keys])

        # Common content relationships
        many_to_many :descriptions, Resolvinator.Content.Description,
          join_through: unquote(opts[:description_table])

        # Content type relationships
        many_to_many :problems, Resolvinator.Content.Problem,
          join_through: "#{unquote(opts[:type_name])}_problem_relationships",
          on_replace: :delete

        many_to_many :solutions, Resolvinator.Content.Solution,
          join_through: "#{unquote(opts[:type_name])}_solution_relationships",
          on_replace: :delete

        many_to_many :advantages, Resolvinator.Content.Advantage,
          join_through: "#{unquote(opts[:type_name])}_advantage_relationships",
          on_replace: :delete

        # Insert the additional schema definitions here
        unquote(additional_schema)

        timestamps(type: :utc_datetime)
      end

      def changeset(content, attrs) do
        content
        |> cast(attrs, [:name, :desc, :creator_id, :upvotes, :downvotes, :status, :rejection_reason])
        |> validate_required([:name, :desc, :creator_id])
        |> validate_inclusion(:status, @status_values)
        |> foreign_key_constraint(:creator_id)
      end

      # Common functions for all content types
      def upvote(content), do: change(content, %{upvotes: content.upvotes + 1})
      def downvote(content), do: change(content, %{downvotes: content.downvotes + 1})
      
      def approve(content), do: change(content, %{status: "approved"})
      def reject(content, reason), do: change(content, %{status: "rejected", rejection_reason: reason})
    end
  end
end 