defmodule Resolvinator.QueryHelpers do
  import Ecto.Query

  def paginate(query, %{"number" => page_number, "size" => page_size}) do
    page_number = String.to_integer(page_number)
    page_size = String.to_integer(page_size)
    
    query
    |> limit(^page_size)
    |> offset(^((page_number - 1) * page_size))
  end

  def handle_includes(query, includes) when is_binary(includes) do
    includes
    |> String.split(",")
    |> Enum.map(&String.split(&1, "."))
    |> handle_includes(query)
  end

  def handle_includes(query, []), do: query
  def handle_includes(query, includes) when is_list(includes), do: preload(query, ^includes)

  def apply_filters(query, filters) when is_map(filters) do
    Enum.reduce(filters, query, fn
      {"status", value}, query -> where(query, [r], r.status == ^value)
      {"priority", value}, query -> where(query, [r], r.priority == ^value)
      {"search", term}, query -> 
        where(query, [r], ilike(r.name, ^"%#{term}%") or ilike(r.description, ^"%#{term}%"))
      {"created_after", date}, query -> 
        where(query, [r], r.inserted_at >= ^date)
      {"created_before", date}, query -> 
        where(query, [r], r.inserted_at <= ^date)
      _, query -> query
    end)
  end

  def apply_sorting(query, sort_params) when is_binary(sort_params) do
    sort_params
    |> String.split(",")
    |> Enum.reduce(query, fn
      "+" <> field, query -> order_by(query, [r], asc: field(r, ^String.to_atom(field)))
      "-" <> field, query -> order_by(query, [r], desc: field(r, ^String.to_atom(field)))
      field, query -> order_by(query, [r], asc: field(r, ^String.to_atom(field)))
    end)
  end
end 