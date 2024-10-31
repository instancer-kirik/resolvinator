defmodule ResolvinatorWeb.SessionController do
  use ResolvinatorWeb, :controller

  alias Resolvinator.Accounts
  alias Resolvinator.Guardian

  def create(conn, %{"email" => email, "password" => password}) do
    case Accounts.authenticate_user(email, password) do
      {:ok, user} ->
        {:ok, access_token, _claims} = 
          Guardian.encode_and_sign(user, %{}, token_type: "access")
        {:ok, refresh_token, _claims} = 
          Guardian.encode_and_sign(user, %{}, token_type: "refresh")
        
        conn
        |> put_status(:ok)
        |> json(%{
          data: %{
            access_token: access_token,
            refresh_token: refresh_token,
            user: %{
              id: user.id,
              email: user.email,
              name: user.name,
              role: user.role
            }
          }
        })

      {:error, _reason} ->
        conn
        |> put_status(:unauthorized)
        |> json(%{error: "Invalid credentials"})
    end
  end

  def refresh(conn, %{"refresh_token" => refresh_token}) do
    case Guardian.exchange(refresh_token, "refresh", "access") do
      {:ok, _old_stuff, {new_access_token, _new_claims}} ->
        json(conn, %{data: %{access_token: new_access_token}})
      
      {:error, _reason} ->
        conn
        |> put_status(:unauthorized)
        |> json(%{error: "Invalid refresh token"})
    end
  end

  def delete(conn, _params) do
    case Guardian.Plug.current_token(conn) do
      nil ->
        send_resp(conn, :no_content, "")
      
      token ->
        Guardian.revoke(token)
        send_resp(conn, :no_content, "")
    end
  end
end 