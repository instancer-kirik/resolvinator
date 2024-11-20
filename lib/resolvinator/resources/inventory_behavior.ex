defmodule Resolvinator.Resources.InventoryBehavior do
  @moduledoc """
  Common behavior for inventory-related schemas
  """

  defmacro __using__(opts) do
    quote do
      use Ecto.Schema
      use Resolvinator.Comments.Commentable
      import Ecto.Changeset
      @primary_key {:id, :binary_id, autogenerate: true}
      @foreign_key_type :binary_id
      @timestamps_opts [type: :utc_datetime]
      @type_name unquote(opts[:type_name] || raise "type_name is required")
      @status_values ~w(active inactive discontinued pending)

      schema unquote(opts[:table_name] || raise "table_name is required") do
        # Common inventory fields
        field :name, :string
        field :description, :string
        field :category, :string
        field :status, :string, default: "active"
        field :metadata, :map, default: %{}
        field :notes, :string

        # Common relationships
        belongs_to :creator, VES.Accounts.User
        belongs_to :project, Resolvinator.Projects.Project

        # Additional schema fields provided by the implementing module
        unquote(opts[:additional_schema] || quote do end)

        timestamps(type: :utc_datetime)
      end

      # Common changeset validations
      def base_changeset(struct, attrs) do
        struct
        |> cast(attrs, [:name, :description, :category, :status, :metadata, :notes, :creator_id, :project_id])
        |> validate_required([:name, :status])
        |> validate_inclusion(:status, @status_values)
        |> foreign_key_constraint(:creator_id)
        |> foreign_key_constraint(:project_id)
      end
    end
  end
end
