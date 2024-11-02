defmodule Resolvinator.Messages do
  @moduledoc """
  The Messages context.
  """
  
  import Ecto.Query, warn: false
  alias Resolvinator.Repo
  alias Resolvinator.Messages.Message

  @doc """
  Returns the list of messages.
  """
  def list_messages do
    Repo.all(Message)
  end

  @doc """
  Gets a single message.
  """
  def get_message!(id), do: Repo.get!(Message, id)

  @doc """
  Creates a message.
  """
  def create_message(attrs \\ %{}) do
    %Message{}
    |> Message.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a message.
  """
  def update_message(%Message{} = message, attrs) do
    message
    |> Message.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a message.
  """
  def delete_message(%Message{} = message) do
    Repo.delete(message)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking message changes.
  """
  def change_message(%Message{} = message, attrs \\ %{}) do
    Message.changeset(message, attrs)
  end

  @doc """
  Lists messages for a specific user.
  """
  def list_messages_for_user(user_id) do
    Message
    |> where([m], m.to_user_id == ^user_id or m.from_user_id == ^user_id)
    |> order_by([m], desc: m.inserted_at)
    |> Repo.all()
  end

  @doc """
  Lists unread messages for a specific user.
  """
  def list_unread_messages(user_id) do
    Message
    |> where([m], m.to_user_id == ^user_id and m.read == false)
    |> Repo.all()
  end

  @doc """
  Marks a message as read.
  """
  def mark_as_read(%Message{} = message) do
    message
    |> Message.changeset(%{read: true})
    |> Repo.update()
  end

  @doc """
  Searches messages with fuzzy text matching and optional time bounds.
  # Search for messages containing "hello" and "world"
    Messages.search_messages(query: "hello world")

    # Search with time bounds
    Messages.search_messages(
    query: "important",
    from_date: ~N[2024-01-01 00:00:00],
    to_date: ~N[2024-03-31 23:59:59]
    )

    # Search user's messages
    Messages.search_messages(
    query: "project update",
    user_id: current_user.id,
    limit: 20,
    offset: 0
    )

    # Just get recent messages
    Messages.search_messages(
    from_date: DateTime.utc_now() |> DateTime.add(-7, :day),
    limit: 50
    )
  Options:
    * :query - Text to search for
    * :user_id - Filter by user (sender or recipient)
    * :from_date - Start date (inclusive)
    * :to_date - End date (inclusive)
    * :limit - Maximum number of results (default: 50)
    * :offset - Number of results to skip (default: 0)
  """
  def search_messages(opts \\ []) do
    base_query = Message

    # Handle search text first to make ts_query available for ranking
    {query, ts_query} = if search_text = opts[:query] do
      # Convert search text to tsquery format
      ts_query = search_text
        |> String.trim()
        |> String.split(" ")
        |> Enum.map(&"#{&1}:*")  # Add prefix matching
        |> Enum.join(" & ")      # AND operator
      
      query = from m in base_query,
        where: fragment("to_tsvector('english', content) @@ to_tsquery('english', ?)", ^ts_query)
      
      {query, ts_query}
    else
      {base_query, nil}
    end

    # Apply filters
    query = if user_id = opts[:user_id] do
      from m in query,
        where: m.from_user_id == ^user_id or m.to_user_id == ^user_id
    else
      query
    end

    query = if from_date = opts[:from_date] do
      from m in query,
        where: m.inserted_at >= ^from_date
    else
      query
    end

    query = if to_date = opts[:to_date] do
      from m in query,
        where: m.inserted_at <= ^to_date
    else
      query
    end

    # Add ranking if there's a search query
    query = if ts_query do
      from m in query,
        order_by: [
          desc: fragment("ts_rank(to_tsvector('english', content), to_tsquery('english', ?))", ^ts_query),
          desc: m.inserted_at
        ]
    else
      from m in query,
        order_by: [desc: m.inserted_at]
    end

    # Add pagination
    limit = opts[:limit] || 50
    offset = opts[:offset] || 0
    
    query = from m in query,
      limit: ^limit,
      offset: ^offset

    Repo.all(query)
  end
end
