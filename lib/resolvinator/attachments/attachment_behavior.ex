defmodule Resolvinator.Attachments.AttachmentBehavior do
  @moduledoc """
  Common behavior for attachment-related schemas
  """

  defmacro __using__(opts) do
    quote do
      use Flint.Schema
      import Ecto.Changeset

      @type_name unquote(opts[:type_name] || raise "type_name is required")
      @attachable_types ~w(Risk Mitigation Impact MitigationTask)

      schema unquote(opts[:table_name] || raise "table_name is required") do
        field :filename, :string
        field :content_type, :string
        field :size, :integer
        field :path, :string
        field :description, :string
        field :metadata, :map, default: %{}

        # Polymorphic association fields
        field :attachable_type, :string
        field :attachable_id, :integer

        belongs_to :creator, Resolvinator.Accounts.User

        # Additional schema fields provided by the implementing module
        unquote(opts[:additional_schema] || quote do end)

        timestamps(type: :utc_datetime)
      end

      def base_changeset(struct, attrs) do
        struct
        |> cast(attrs, [
          :filename, :content_type, :size, :path, :description,
          :attachable_type, :attachable_id, :creator_id, :metadata
        ])
        |> validate_required([
          :filename, :content_type, :size, :path,
          :attachable_type, :attachable_id, :creator_id
        ])
        |> validate_inclusion(:attachable_type, @attachable_types)
        |> foreign_key_constraint(:creator_id)
      end
    end
  end
end
