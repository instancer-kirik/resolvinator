defmodule Resolvinator.Types.TsVector do
  @moduledoc """
  Custom Ecto type for PostgreSQL's tsvector type.
  """
  use Ecto.Type

  def type, do: :tsvector

  def cast(value) when is_binary(value), do: {:ok, value}
  def cast(_), do: :error

  def load(value), do: {:ok, value}

  def dump(value) when is_binary(value), do: {:ok, value}
  def dump(_), do: :error
end
