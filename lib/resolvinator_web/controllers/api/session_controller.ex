defmodule ResolvinatorWeb.API.SessionController do
  use ResolvinatorWeb, :controller
  alias Resolvinator.{Accounts, Guardian}

  def create(conn, %{"email" => email, "password" => password}) do
    case Accounts.authenticate_user(email, password) do
      {:ok, user} ->
        {:ok, access_token, _claims} = Guardian.encode_and_sign(user)
        {:ok, refresh_token, _claims} = Guardian.encode_and_sign(user, %{}, token_type: "refresh")

        conn
        |> put_status(:ok)
        |> render("tokens.json", access_token: access_token, refresh_token: refresh_token)
      {:error, :invalid_credentials} ->
        conn
        |> put_status(:unauthorized)
        |> json(%{error: "Invalid credentials"})
    end
  end

  def refresh(conn, %{"refresh_token" => refresh_token}) do
    case Guardian.exchange(refresh_token, "refresh", "access") do
      {:ok, _old_stuff, {new_token, _new_claims}} ->
        conn
        |> put_status(:ok)
        |> json(%{access_token: new_token})
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