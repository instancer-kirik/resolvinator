defmodule Resolvinator.Schema.ContentFields do
  defmacro __using__(_opts) do
    quote do
      import Resolvinator.Schema.ContentFields
    end
  end

  defmacro content_fields do
    quote do
      field :name, :string
      field :description, :string
      field :status, :string, default: "initial"
      field :visibility, :string, default: "public"
      field :metadata, :map, default: %{}
      field :tags, {:array, :string}, default: []
      field :priority, :integer
      field :voting, :map, default: %{upvotes: 0, downvotes: 0}
      field :moderation, :map, default: %{status: "pending", reason: nil}
      
      belongs_to :creator, Resolvinator.Acts.User, type: :binary_id
      belongs_to :project, Resolvinator.Projects.Project, type: :binary_id
    end
  end

  defmacro add_content_fields do
    quote do
      add :id, :binary_id, primary_key: true
      add :name, :string, null: false
      add :description, :string, null: false
      add :status, :string, default: "initial"
      add :visibility, :string, default: "public"
      add :metadata, :map, default: %{}
      add :tags, {:array, :string}, default: []
      add :priority, :integer
      add :voting, :map, default: %{upvotes: 0, downvotes: 0}
      add :moderation, :map, default: %{status: "pending", reason: nil}
      add :creator_id, references(:users, type: :binary_id, on_delete: :restrict)
      add :project_id, references(:projects, type: :binary_id, on_delete: :nilify_all)

      timestamps(type: :utc_datetime)
    end
  end

  defmacro add_content_indexes(table) do
    quote do
      create index(unquote(table), [:creator_id])
      create index(unquote(table), [:project_id])
      create index(unquote(table), [:name])
      create index(unquote(table), [:status])
    end
  end
end 