defmodule Resolvinator.Browse do
  @moduledoc """
  The Browse context handles cross-application content discovery and search functionality.
  """

  alias Seek.Query
  alias Seek.Result
  alias Seek.Provider

  @doc """
  Performs a faceted search across multiple content types.
  """
  def faceted_search(query, user, opts \\ []) do
    types = Keyword.get(opts, :types, ["project", "task", "resource", "document"])
    page = Keyword.get(opts, :page, 1)

    types
    |> Enum.reduce(%{}, fn type, acc ->
      case search_type(type, query, user, page: page) do
        {:ok, results} -> Map.put(acc, type, results)
        {:error, _} -> acc
      end
    end)
  end

  @doc """
  Performs a search for a specific content type.
  """
  def search_type(type, query, user, opts \\ []) do
    page = Keyword.get(opts, :page, 1)
    per_page = Keyword.get(opts, :per_page, 10)

    query_params = %{
      query: query,
      filters: %{
        type: type,
        user_id: user.id
      },
      page: page,
      per_page: per_page
    }

    case Query.execute(query_params) do
      {:ok, results} ->
        {:ok, format_results(results, page)}
      error ->
        error
    end
  end

  @doc """
  Suggests search terms based on user's search history and content.
  """
  def suggest_search_terms(query, user) do
    suggestions =
      Query.suggest(query, %{
        user_id: user.id,
        limit: 5
      })

    case suggestions do
      {:ok, terms} -> terms
      _ -> []
    end
  end

  @doc """
  Returns trending searches for the user.
  """
  def trending_searches(user) do
    case Query.trending_searches(%{user_id: user.id, limit: 5}) do
      {:ok, terms} -> terms
      _ -> []
    end
  end

  @doc """
  Gets user-specific content across all applications.
  """
  def get_user_content(user) do
    providers = Provider.list_providers()

    providers
    |> Enum.reduce(%{}, fn provider, acc ->
      case provider.get_user_content(user) do
        {:ok, content} ->
          type = provider.content_type()
          Map.put(acc, type, content)
        _ ->
          acc
      end
    end)
  end

  defp format_results(results, page) do
    %{
      entries: results.hits,
      page_number: page,
      total_entries: results.total,
      total_pages: ceil(results.total / length(results.hits))
    }
  end
end
