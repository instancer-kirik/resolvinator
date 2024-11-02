defmodule ResolvinatorWeb.API.JSONHelpers do
  def maybe_add_relationship(relationships, _key, nil, _formatter, _includes), do: relationships
  def maybe_add_relationship(relationships, key, data, formatter, includes) when not is_list(data) do
    if key in includes do
      Map.put(relationships, key, formatter.(data))
    else
      relationships
    end
  end
  def maybe_add_relationship(relationships, key, data, formatter, includes) when is_list(data) do
    if key in includes do
      Map.put(relationships, key, Enum.map(data, &formatter.(&1)))
    else
      relationships
    end
  end

  def parse_includes(includes) when is_list(includes), do: includes
  def parse_includes(includes) when is_binary(includes) do
    String.split(includes, ",", trim: true)
  end
  def parse_includes(_), do: []

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

  @doc """
  Filters sensitive user data based on the current user's permissions
  """
  def filter_user_attributes(user, current_user) do
    cond do
      # Admins can see everything
      current_user && current_user.is_admin ->
        user
      # Users can see their own full profile
      current_user && current_user.id == user.id ->
        user
      # Public view hides sensitive data
      true ->
        Map.drop(user, [:preferences, :confirmed_at, :banned_at, :is_admin])
    end
  end
end 