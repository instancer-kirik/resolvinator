defmodule Resolvinator.Types.TsVector do
  @behaviour Ecto.Type

  def type, do: :tsvector

  # Casting from external data (e.g. forms, API)
  def cast(value) when is_binary(value), do: {:ok, value}
  def cast(_), do: :error

  # Loading from the database
  def load(value), do: {:ok, value}

  # Dumping to the database
  def dump(value) when is_binary(value), do: {:ok, value}
  def dump(_), do: :error
end
