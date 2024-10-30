defmodule ResolvinatorWeb.SessionController do
  use ResolvinatorWeb, :controller

  alias Resolvinator.Accounts

  def create(conn, %{"email" => email, "password" => password}) do
    case Accounts.authenticate_user(email, password) do
      {:ok, user} ->
        token = Accounts.generate_user_token(user)
        
        conn
        |> put_status(:ok)
        |> json(%{
          data: %{
            token: token,
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

  def delete(conn, _params) do
    token = get_session(conn, :user_token)
    
    if token do
      Accounts.delete_session_token(token)
    end

    conn
    |> delete_session(:user_token)
    |> json(%{data: %{message: "Logged out successfully"}})
  end
end 