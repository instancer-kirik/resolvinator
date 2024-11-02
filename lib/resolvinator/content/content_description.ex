defmodule Resolvinator.Content.ContentDescription do
  @moduledoc """
  Common schema for content-description relationships
  """
  
  defmacro __using__(opts) do
    quote do
      use Ecto.Schema
      import Ecto.Changeset

      schema unquote(opts[:table_name]) do
        belongs_to unquote(opts[:content_type]), unquote(opts[:content_module])
        belongs_to :description, Resolvinator.Content.Description

        timestamps()
      end

      def changeset(content_description, attrs) do
        content_description
        |> cast(attrs, [unquote(opts[:foreign_key]), :description_id])
        |> validate_required([unquote(opts[:foreign_key]), :description_id])
        |> unique_constraint([unquote(opts[:foreign_key]), :description_id])
      end
    end
  end
end 