defmodule ResolvinatorWeb.JSONHelpers do
  @moduledoc """
  Shared JSON formatting helpers
  """

  def paginate(data, page_info) do
    %{
      data: data,
      meta: %{
        total_count: page_info.total_count,
        page_size: page_info.page_size,
        page_number: page_info.page_number,
        total_pages: page_info.total_pages
      },
      links: %{
        first: page_info.first_page_url,
        last: page_info.last_page_url,
        prev: page_info.prev_page_url,
        next: page_info.next_page_url
      }
    }
  end

  def format_error(changeset) do
    %{
      errors: Ecto.Changeset.traverse_errors(changeset, &translate_error/1)
    }
  end

  def format_error(type, message) when is_atom(type) do
    %{
      error: %{
        type: type,
        message: message
      }
    }
  end

  defp translate_error({msg, opts}) do
    Enum.reduce(opts, msg, fn {key, value}, acc ->
      String.replace(acc, "%{#{key}}", fn _ -> to_string(value) end)
    end)
  end

  def maybe_add_relationship(relationships, key, nil, _formatter, _includes), do: relationships
  def maybe_add_relationship(relationships, key, data, _formatter, includes) when not is_list(data) and key not in includes, do: 
    Map.put(relationships, key, %{id: data.id, type: key})
  def maybe_add_relationship(relationships, key, data, formatter, includes) when not is_list(data) and key in includes, do: 
    Map.put(relationships, key, formatter.(data))
  def maybe_add_relationship(relationships, key, data, _formatter, includes) when is_list(data) and key not in includes, do: 
    Map.put(relationships, key, Enum.map(data, &%{id: &1.id, type: key}))
  def maybe_add_relationship(relationships, key, data, formatter, includes) when is_list(data) and key in includes, do: 
    Map.put(relationships, key, Enum.map(data, formatter))

  def user_data(user) do
    %{
      id: user.id,
      type: "user",
      attributes: %{
        email: user.email,
        name: user.name
      }
    }
  end

  def user_reference(nil), do: nil
  def user_reference(user_id), do: %{id: user_id, type: "user"}
end 