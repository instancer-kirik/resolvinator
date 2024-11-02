defmodule Resolvinator.QueryHelpers do
  import Ecto.Query

  def paginate(query, %{"number" => page_number, "size" => page_size}) do
    page_number = String.to_integer(page_number)
    page_size = String.to_integer(page_size)
    
    total_count = Resolvinator.Repo.aggregate(query, :count)
    total_pages = ceil(total_count / page_size)

    results = query
    |> limit(^page_size)
    |> offset(^((page_number - 1) * page_size))
    |> Resolvinator.Repo.all()

    page_info = %{
      total_count: total_count,
      page_size: page_size,
      page_number: page_number,
      total_pages: total_pages,
      # Add URL helpers - adjust your URL structure as needed
      first_page_url: build_url(1, page_size),
      last_page_url: build_url(total_pages, page_size),
      prev_page_url: if(page_number > 1, do: build_url(page_number - 1, page_size)),
      next_page_url: if(page_number < total_pages, do: build_url(page_number + 1, page_size))
    }

    {results, page_info}
  end

  defp build_url(page_number, page_size) do
    "?page[number]=#{page_number}&page[size]=#{page_size}"
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

  def exclude_hidden(query) do
    from q in query,
      where: is_nil(q.hidden) or q.hidden == false
  end

  def include_hidden(query) do
    query
  end

  def only_hidden(query) do
    from q in query,
      where: q.hidden == true
  end
end 