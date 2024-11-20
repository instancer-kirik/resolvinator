defmodule ResolvinatorWeb.API.SessionController do
  use ResolvinatorWeb, :controller
  
  alias VES.Accounts
  alias VES.Guardian

  def create(conn, %{"email" => email, "password" => password}) do
    case Accounts.Auth.authenticate_user(email, password) do
      {:ok, user} ->
        {:ok, access_token, _claims} = Guardian.encode_and_sign(user)
        {:ok, refresh_token, _claims} = Guardian.encode_and_sign(user, %{}, token_type: "refresh")

        conn
        |> put_status(:ok)
        |> render("tokens.json", access_token: access_token, refresh_token: refresh_token)

      {:error, _reason} ->
        conn
        |> put_status(:unauthorized)
        |> json(%{error: "Invalid credentials"})
    end
  end

  def create(conn, %{"github_token" => github_token}) do
    case Accounts.GitHub.get_user_profile(github_token) do
      {:ok, github_user} ->
        case Accounts.GitHub.find_or_create_user(github_user, github_token) do
          {:ok, user} ->
            {:ok, access_token, _claims} = Guardian.encode_and_sign(user)
            {:ok, refresh_token, _claims} = Guardian.encode_and_sign(user, %{}, token_type: "refresh")

            conn
            |> put_status(:ok)
            |> render("tokens.json", access_token: access_token, refresh_token: refresh_token)

          {:error, _reason} ->
            conn
            |> put_status(:unprocessable_entity)
            |> json(%{error: "Failed to create user from GitHub account"})
        end

      {:error, _reason} ->
        conn
        |> put_status(:unauthorized)
        |> json(%{error: "Invalid GitHub token"})
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