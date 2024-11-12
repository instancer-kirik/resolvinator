defmodule Resolvinator.Shared.ExtensibleEnum do
  @moduledoc """
  A behaviour module for implementing extensible enums.
  """

  @callback values() :: [atom()]
  @callback validate(term()) :: boolean()
  @callback to_string(atom()) :: String.t()
  @callback from_string(String.t()) :: {:ok, atom()} | {:error, String.t()}
  
  defmacro __using__(opts) do
    quote do
      @behaviour Resolvinator.Shared.ExtensibleEnum
      
      @values unquote(opts[:values])
      @string_mapping for value <- @values, into: %{}, do: {Atom.to_string(value), value}
      @atom_mapping for {string, value} <- @string_mapping, into: %{}, do: {value, string}

      def values, do: @values
      
      def validate(value) when is_atom(value), do: value in @values
      def validate(_), do: false
      
      def to_string(value) when is_atom(value), do: Map.get(@atom_mapping, value)
      def to_string(_), do: nil
      
      def from_string(string) when is_binary(string) do
        case Map.get(@string_mapping, string) do
          nil -> {:error, "Invalid value: #{string}"}
          value -> {:ok, value}
        end
      end
      def from_string(_), do: {:error, "Input must be a string"}
    end
  end
end 