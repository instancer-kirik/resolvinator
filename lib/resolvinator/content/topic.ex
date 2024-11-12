defmodule Resolvinator.Content.Topic do
  use Ecto.Schema
  import Ecto.Changeset
  use Resolvinator.Schema.ContentFields

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "topics" do
    content_fields()
    
    # Topic-specific fields
    field :slug, :string
    field :position, :integer
    
    # Feature flags
    field :is_featured, :boolean, default: false
    field :is_hidden, :boolean, default: false
    field :is_private, :boolean, default: false
    field :is_age_restricted, :boolean, default: false
    field :is_premium, :boolean, default: false
    field :is_archived, :boolean, default: false
    field :is_locked, :boolean, default: false
    
    # Categorization
    field :category, :string
    field :level, :string
    field :difficulty, :integer  # 1-5 scale
    field :estimated_time, :integer  # in minutes
    
    # Content organization
    field :prerequisites, {:array, :string}, default: []
    field :learning_objectives, {:array, :string}, default: []
    field :content_count, :integer, default: 0
    field :sort_order, :integer
    
    # Extended metadata
    field :custom_metadata, :map, default: %{
      "age_range" => nil,         # e.g., "13-18"
      "target_audience" => nil,   # e.g., "beginners", "professionals"
      "required_tools" => [],     # list of required tools/software
      "languages" => [],          # supported languages
      "certifications" => [],     # related certifications
      "skills" => [],            # skills covered
      "industries" => [],        # relevant industries
      "frameworks" => [],        # related frameworks/methodologies
      "resources" => %{          # additional resources
        "external_links" => [],
        "documents" => [],
        "videos" => []
      },
      "schedule" => %{           # if part of a scheduled curriculum
        "start_date" => nil,
        "end_date" => nil,
        "sessions" => []
      }
    }

    # Access control
    field :access_requirements, :map, default: %{
      "roles" => [],             # required roles
      "permissions" => [],       # required permissions
      "prerequisites_strict" => false,  # strictly enforce prerequisites
      "organization_only" => false,    # limit to organization members
      "subscription_level" => nil,     # required subscription level
      "beta_access" => false          # beta features access
    }

    # Statistics and metrics
    field :stats, :map, default: %{
      "views" => 0,
      "completions" => 0,
      "avg_rating" => 0.0,
      "review_count" => 0,
      "engagement_score" => 0.0,
      "difficulty_rating" => 0.0,
      "completion_time_avg" => 0,
      "success_rate" => 0.0
    }

    # Hierarchical relationship
    belongs_to :parent, __MODULE__

    # Generic content relationships
    has_many :content_relationships, Resolvinator.Content.ContentTopicRelationship
    
    # Topic-to-topic relationships
    has_many :topic_relationships, Resolvinator.Content.TopicRelationship
    many_to_many :related_topics, __MODULE__,
      join_through: Resolvinator.Content.TopicRelationship,
      join_keys: [topic_id: :id, related_topic_id: :id],
      on_replace: :delete

    timestamps(type: :utc_datetime)
  end

  def changeset(topic, attrs) do
    topic
    |> cast(attrs, [
      # Content fields from ContentFields
      :name, :desc, :status, :visibility, :metadata, 
      :tags, :priority, :creator_id, :project_id,
      # Topic-specific fields
      :slug, :position, :sort_order, :difficulty, :estimated_time,
      # Feature flags
      :is_featured, :is_hidden, :is_private, :is_age_restricted,
      :is_premium, :is_archived, :is_locked,
      # Categorization
      :category, :level,
      # Content organization
      :prerequisites, :learning_objectives, :content_count,
      # Extended metadata
      :custom_metadata, :access_requirements, :stats,
      # Relationships
      :parent_id
    ])
    |> validate_required([
      :name, :desc, :slug, :category, :level,
      :creator_id, :project_id
    ])
    |> validate_inclusion(:level, ~w(beginner intermediate advanced expert))
    |> validate_inclusion(:category, ~w(core supplementary specialized))
    |> validate_number(:difficulty, greater_than_or_equal_to: 1, less_than_or_equal_to: 5)
    |> validate_number(:estimated_time, greater_than: 0)
    |> unique_constraint([:slug, :project_id])
    |> foreign_key_constraint(:creator_id)
    |> foreign_key_constraint(:project_id)
    |> foreign_key_constraint(:parent_id)
    |> validate_metadata()
  end

  defp validate_metadata(changeset) do
    changeset
    |> validate_custom_metadata()
    |> validate_access_requirements()
    |> validate_stats()
  end

  defp validate_custom_metadata(changeset) do
    # Add custom validation for metadata structure
    changeset
  end

  defp validate_access_requirements(changeset) do
    # Add validation for access requirements
    changeset
  end

  defp validate_stats(changeset) do
    # Add validation for stats
    changeset
  end
end 