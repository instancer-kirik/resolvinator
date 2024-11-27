defmodule Resolvinator.Auth do
  @moduledoc """
  Authentication context for token verification and related functions.
  """

  alias Resolvinator.Acts
  alias Resolvinator.Acts.UserToken

  @doc """
  Verifies a token and returns the associated user claims.
  """
  def verify_token(token) when is_binary(token) do
    case UserToken.verify_session_token_query(token) do
      {:ok, query} ->
        case Resolvinator.Repo.one(query) do
          nil -> {:error, :invalid_token}
          user -> {:ok, %{user_id: user.id}}
        end
      _ -> {:error, :invalid_token}
    end
  end
  def verify_token(_), do: {:error, :invalid_token}
end
