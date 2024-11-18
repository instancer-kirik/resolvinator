defmodule Resolvinator.Projects.OwnershipToken do
  @moduledoc """
  Handles generation and validation of project ownership tokens.
  Uses Phoenix.Token for secure token generation with project-specific salt.
  """
  
  alias Phoenix.Token
  alias Resolvinator.Projects.Project

  # Token valid for 1 year (in seconds)
  @token_max_age 31_536_000
  @token_salt "project_ownership_token"

  @doc """
  Generates a new ownership token for a project.
  The token includes project ID and a random nonce for uniqueness.
  """
  def generate(%Project{id: project_id}) do
    nonce = :crypto.strong_rand_bytes(16) |> Base.encode16(case: :lower)
    token_data = %{project_id: project_id, nonce: nonce}
    
    ResolvinatorWeb.Endpoint
    |> Token.sign(@token_salt, token_data)
  end

  @doc """
  Verifies an ownership token for a specific project.
  Returns {:ok, token_data} if valid, {:error, reason} if invalid.
  """
  def verify(token, %Project{id: project_id}) do
    case Token.verify(ResolvinatorWeb.Endpoint, @token_salt, token, max_age: @token_max_age) do
      {:ok, %{project_id: ^project_id} = token_data} -> {:ok, token_data}
      {:ok, _} -> {:error, :invalid_project}
      error -> error
    end
  end

  @doc """
  Generates a new token and returns both the token and its hash.
  The hash is stored in the database while the token is given to the user.
  """
  def generate_token_pair(%Project{} = project) do
    token = generate(project)
    hash = :crypto.hash(:sha256, token) |> Base.encode16(case: :lower)
    {token, hash}
  end

  @doc """
  Verifies a token against a stored hash.
  """
  def verify_token_hash(token, stored_hash, project) do
    with {:ok, _} <- verify(token, project),
         ^stored_hash <- :crypto.hash(:sha256, token) |> Base.encode16(case: :lower) do
      :ok
    else
      _ -> {:error, :invalid_token}
    end
  end
end
