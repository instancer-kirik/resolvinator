defmodule Resolvinator.Schema do
  @moduledoc """
  Base schema that sets up binary_id as the default primary key type and foreign key type.
  This ensures consistency across all schemas in the application.
  """

  defmacro __using__(_) do
    quote do
      use Ecto.Schema
      @primary_key {:id, :binary_id, autogenerate: true}
      @foreign_key_type :binary_id
      @derive {Phoenix.Param, key: :id}
    end
  end
end
