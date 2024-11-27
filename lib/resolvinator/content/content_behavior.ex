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
    type_name = opts[:type_name]

    quote do
      use Ecto.Schema
      use Flint.Schema
      import Ecto.Changeset
      import Ecto.Query

      @primary_key {:id, :binary_id, autogenerate: true}
      @foreign_key_type :binary_id
      @timestamps_opts [type: :utc_datetime]
      @derive {Jason.Encoder, except: [:__meta__, :__struct__]}

      @status_values ~w(initial pending approved rejected draft review published archived)
      @type_name unquote(opts[:type_name]) || raise "type_name is required"
      @relationship_table unquote(opts[:relationship_table]) || raise "relationship_table is required"
      @description_table unquote(opts[:description_table]) || raise "description_table is required"

      schema unquote(opts[:table_name] || raise "table_name is required") do
        # Basic content fields
        field :name, :string
        field :description, :string
        field :status, :string, default: "initial"
        field :visibility, :string, default: "public"
        field :metadata, :map, default: %{}
        field :tags, {:array, :string}, default: []
        field :priority, :integer

        # Embedded schemas
        embeds_one :voting, Voting, on_replace: :delete
        embeds_one :moderation, Moderation, on_replace: :delete
        embeds_many :impacts, Resolvinator.Content.Impact, on_replace: :delete

        # Common relationships
        belongs_to :creator, Acts.User
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

        # Add content type specific relationships based on type_name
        unquote(content_type_relationships(type_name))

        timestamps(type: :utc_datetime)
      end

      # Now add Commentable behavior after schema is defined
      use Resolvinator.Comments.Commentable

      def base_changeset(struct, attrs) do
        struct
        |> cast(attrs, [
          :name, :description, :status, :visibility, :metadata, :tags,
          :priority, :creator_id, :project_id
        ])
        |> cast_embed(:voting)
        |> cast_embed(:moderation)
        |> cast_embed(:impacts)
        |> validate_required([:name, :description, :creator_id])
        |> validate_inclusion(:status, @status_values)
        |> validate_inclusion(:visibility, ~w(public private))
        |> validate_number(:priority, greater_than_or_equal_to: 0)
        |> foreign_key_constraint(:creator_id)
        |> foreign_key_constraint(:project_id)
        |> put_default_arrays()
      end

      # Add helper functions for array defaults
      defp put_default_arrays(changeset) do
        Enum.reduce(array_fields(), changeset, fn field, acc ->
          put_change_if_nil(acc, field, [])
        end)
      end

      defp put_change_if_nil(changeset, field, default) do
        if get_field(changeset, field) == nil do
          put_change(changeset, field, default)
        else
          changeset
        end
      end

      # Get array fields from schema
      defp array_fields do
        __MODULE__.__schema__(:fields)
        |> Enum.filter(fn field ->
          case __MODULE__.__schema__(:type, field) do
            {:array, _} -> true
            _ -> false
          end
        end)
      end

      # Define the default changeset function that can be overridden
      def changeset(struct, attrs) do
        struct
        |> base_changeset(attrs)
        |> cast_assoc(:impacts)
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
        Enum.map(fields, fn
          {name, {:array, type}} ->
            # Handle array types specifically
            quote do: field(unquote(name), {:array, unquote(type)})
          {name, {type, opts}} ->
            quote do: field(unquote(name), unquote(type), unquote(opts))
          {name, type} ->
            quote do: field(unquote(name), unquote(type))
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

  # Helper to define relationships based on content type
  defp content_type_relationships(:lesson) do
    quote do
      has_many :problems, Resolvinator.Content.Problem
      has_many :solutions, Resolvinator.Content.Solution
      has_many :advantages, Resolvinator.Content.Advantage
      many_to_many :related_lessons, Resolvinator.Content.Lesson,
        join_through: "lesson_relationships",
        join_keys: [lesson_id: :id, related_lesson_id: :id],
        on_replace: :delete
    end
  end

  defp content_type_relationships(:advantage) do
    quote do
      has_many :problems, Resolvinator.Content.Problem
      has_many :solutions, Resolvinator.Content.Solution
      has_many :lessons, Resolvinator.Content.Lesson
      many_to_many :related_advantages, Resolvinator.Content.Advantage,
        join_through: "advantage_relationships",
        join_keys: [advantage_id: :id, related_advantage_id: :id],
        on_replace: :delete
    end
  end

  defp content_type_relationships(:problem) do
    quote do
      has_many :solutions, Resolvinator.Content.Solution
      has_many :lessons, Resolvinator.Content.Lesson
      has_many :advantages, Resolvinator.Content.Advantage
    end
  end

  defp content_type_relationships(:solution) do
    quote do
      has_many :problems, Resolvinator.Content.Problem
      has_many :lessons, Resolvinator.Content.Lesson
      has_many :advantages, Resolvinator.Content.Advantage
      many_to_many :related_solutions, Resolvinator.Content.Solution,
        join_through: "solution_relationships",
        join_keys: [solution_id: :id, related_solution_id: :id],
        on_replace: :delete
    end
  end

  defp content_type_relationships(_), do: []
end
