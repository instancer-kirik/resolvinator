defmodule Resolvinator.Content.ContentBehavior do
  @moduledoc """
  Common behavior for content types (Problem, Solution, Lesson, Advantage)
  """

  defmodule Voting do
    use Ecto.Schema

    @primary_key false
    embedded_schema do
      field :upvotes, :integer, default: 0
      field :downvotes, :integer, default: 0
      field :score, :float, virtual: true
    end
  end

  defmodule Moderation do
    use Ecto.Schema

    @primary_key false
    embedded_schema do
      field :rejection_reason, :string
      field :moderated_at, :utc_datetime
      field :moderated_by_id, :binary_id
      field :notes, :string
    end
  end

  defmacro __using__(opts) do
    additional_schema = Keyword.get(opts, :additional_schema, [])

    quote do
      use Ecto.Schema
      use Flint.Schema
      import Ecto.Changeset
      import Ecto.Query

      @primary_key {:id, :binary_id, autogenerate: true}
      @foreign_key_type :binary_id
      @timestamps_opts [type: :utc_datetime]
      @derive {Jason.Encoder, only: [:id, :name, :desc, :status, :metadata]}

      @status_values ~w(initial pending approved rejected draft review published archived)
      @type_name unquote(opts[:type_name]) || raise "type_name is required"
      @relationship_table unquote(opts[:relationship_table]) || raise "relationship_table is required"
      @description_table unquote(opts[:description_table]) || raise "description_table is required"

      schema unquote(opts[:table_name] || raise "table_name is required") do
        # Basic content fields
        field :name, :string
        field :title, :string  # For backwards compatibility
        field :desc, :string
        field :description, :string  # For backwards compatibility
        field :status, :string, default: "initial"
        field :visibility, :string, default: "public"
        field :metadata, :map, default: %{}
        field :tags, {:array, :string}, default: []
        field :priority, :integer

        # Embedded schemas
        embeds_one :voting, Voting, on_replace: :delete
        embeds_one :moderation, Moderation, on_replace: :delete

        # Common relationships
        belongs_to :creator, Resolvinator.Accounts.User
        belongs_to :project, Resolvinator.Projects.Project

        # Self-referential relationships
        many_to_many :related_content, __MODULE__,
          join_through: @relationship_table,
          join_keys: unquote(opts[:relationship_keys]),
          on_replace: :delete

        # Descriptions
        many_to_many :descriptions, Resolvinator.Content.Description,
          join_through: @description_table,
          join_keys: unquote(opts[:description_keys]),
          on_replace: :delete

        # Comments relationship (moved from Commentable)
        has_many :comments, Resolvinator.Comments.Comment, foreign_key: :content_id

        # Add additional schema fields if provided
        unquote_splicing(process_additional_schema(additional_schema))

        timestamps(type: :utc_datetime)
      end

      # Now add Commentable behavior after schema is defined
      use Resolvinator.Comments.Commentable

      def base_changeset(struct, attrs) do
        struct
        |> cast(attrs, [
          :name, :title, :desc, :description,
          :status, :visibility, :metadata, :tags,
          :priority, :creator_id, :project_id
        ])
        |> cast_embed(:voting)
        |> cast_embed(:moderation)
        |> validate_required([:name, :desc, :creator_id])
        |> validate_inclusion(:status, @status_values)
        |> validate_inclusion(:visibility, ~w(public private))
        |> validate_number(:priority, greater_than_or_equal_to: 0)
        |> foreign_key_constraint(:creator_id)
        |> foreign_key_constraint(:project_id)
      end

      # Define the default changeset function that can be overridden
      def changeset(struct, attrs) do
        base_changeset(struct, attrs)
      end

      # Common content functions
      def upvote(content) do
        voting = content.voting || %Voting{}
        change(content, voting: %{upvotes: (voting.upvotes || 0) + 1})
      end

      def downvote(content) do
        voting = content.voting || %Voting{}
        change(content, voting: %{downvotes: (voting.downvotes || 0) + 1})
      end

      def approve(content), do: change(content, %{status: "approved"})

      def reject(content, reason, user_id) do
        change(content, %{
          status: "rejected",
          moderation: %{
            rejection_reason: reason,
            moderated_at: DateTime.utc_now(),
            moderated_by_id: user_id
          }
        })
      end

      def publish(content), do: change(content, %{status: "published"})
      def archive(content), do: change(content, %{status: "archived"})
      def draft(content), do: change(content, %{status: "draft"})
      def review(content), do: change(content, %{status: "review"})
    end
  end

  # Helper function to process additional schema definitions
  defp process_additional_schema(additional_schema) do
    Enum.flat_map(additional_schema, fn
      {:fields, fields} ->
        Enum.map(fields, fn {name, type} ->
          case type do
            {type, opts} ->
              quote do: field(unquote(name), unquote(type), unquote(opts))
            type ->
              quote do: field(unquote(name), unquote(type))
          end
        end)
      
      {:embeds_many, embeds} ->
        Enum.map(embeds, fn {name, opts} ->
          module = opts[:schema]
          quote do: embeds_many(unquote(name), unquote(module))
        end)
      
      {:embeds_one, embeds} ->
        Enum.map(embeds, fn {name, opts} ->
          module = opts[:module] || opts[:schema]
          quote do: embeds_one(unquote(name), unquote(module))
        end)
      
      {:relationships, rels} ->
        Enum.flat_map(rels, fn
          {:belongs_to, items} ->
            Enum.map(items, fn {name, opts} ->
              quote do: belongs_to(unquote(name), unquote(opts[:module]))
            end)
          
          {:has_many, items} ->
            Enum.map(items, fn {name, opts} ->
              quote do: has_many(unquote(name), unquote(opts[:module]))
            end)
          
          {:many_to_many, items} ->
            Enum.map(items, fn {name, opts} ->
              quote do
                many_to_many unquote(name), unquote(opts[:module]),
                  join_through: unquote(opts[:join_through]),
                  join_keys: unquote(opts[:join_keys]),
                  on_replace: unquote(Keyword.get(opts, :on_replace, :delete))
              end
            end)
        end)
      
      _ -> []
    end)
  end
end
