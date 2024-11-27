defmodule Resolvinator.Guardian do
  use Guardian, otp_app: :resolvinator

  alias Acts
  alias Acts.User
  alias VES.Web3.Wallet

  @token_types %{
    access: "access",
    refresh: "refresh",
    api: "api",
    web3: "web3"
  }

  @doc """
  Generate a subject for a token based on the user and their Web3 wallet if available.
  """
  def subject_for_token(%User{} = user, %{"type" => type} = _claims) when type == @token_types.web3 do
    case Wallet.get_ethereum_address(user) do
      {:ok, address} -> {:ok, "#{user.id}:#{address}"}
      _error -> {:ok, to_string(user.id)}
    end
  end

  def subject_for_token(%User{} = user, _claims) do
    {:ok, to_string(user.id)}
  end

  def subject_for_token(_, _) do
    {:error, :invalid_resource}
  end

  @doc """
  Fetch the resource from token claims, verifying Web3 signatures if applicable.
  """
  def resource_from_claims(%{"sub" => subject, "type" => type} = claims) when type == @token_types.web3 do
    with [user_id, eth_address] <- String.split(subject, ":", parts: 2),
         {:ok, user} <- Accounts.get_user(user_id),
         {:ok, true} <- verify_ethereum_signature(user, eth_address, claims) do
      {:ok, user}
    else
      _ -> {:error, :invalid_web3_signature}
    end
  end

  def resource_from_claims(%{"sub" => id}) do
    case Accounts.get_user(id) do
      {:ok, user} -> {:ok, user}
      _error -> {:error, :resource_not_found}
    end
  end

  def resource_from_claims(_) do
    {:error, :invalid_claims}
  end

  @doc """
  Build claims for different token types with appropriate TTL.
  """
  def build_claims(user, type, _opts) do
    claims = %{
      "typ" => type,
      "roles" => user.roles || [],
      "permissions" => user.permissions || []
    }

    {:ok, claims}
  end

  @doc """
  Verify that the token hasn't been revoked.
  """
  def verify_token(token, _opts) do
    case VES.Guardian.DB.Token.verify(token) do
      {:ok, _} -> {:ok, token}
      {:error, reason} -> {:error, reason}
    end
  end

  @doc """
  After token generation hook to store the token in the database.
  """
  def after_encode_and_sign(resource, claims, token, _opts) do
    with {:ok, _} <- Guardian.DB.after_encode_and_sign(resource, claims["typ"], claims, token) do
      {:ok, token}
    end
  end

  @doc """
  Before token verification hook to check the token in the database.
  """
  def on_verify(claims, token, _opts) do
    with {:ok, _} <- Guardian.DB.on_verify(claims, token) do
      {:ok, claims}
    end
  end

  @doc """
  After token revocation hook to record the revocation in the database.
  """
  def on_revoke(claims, token, _opts) do
    with {:ok, _} <- Guardian.DB.on_revoke(claims, token) do
      {:ok, claims}
    end
  end

  # Private Functions

  defp verify_ethereum_signature(user, eth_address, claims) do
    with {:ok, wallet} <- Wallet.get_wallet(user),
         true <- wallet.address == eth_address,
         {:ok, _} <- Wallet.verify_signature(claims["signature"], claims["message"], eth_address) do
      {:ok, true}
    else
      _ -> {:error, :invalid_signature}
    end
  end
end