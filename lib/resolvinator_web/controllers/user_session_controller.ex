defmodule ResolvinatorWeb.UserSessionController do
  use ResolvinatorWeb, :controller

  alias Acts
  alias ResolvinatorWeb.UserAuth

  def create(conn, %{"_action" => "registered"} = params) do
    create_with_message(conn, params, "Account created successfully!")
  end

  def create(conn, %{"_action" => "password_updated"} = params) do
    conn
    |> put_session(:user_return_to, ~p"/users/settings")
    |> create_with_message(params, "Password updated successfully!")
  end

  def create(conn, %{"_action" => "github_connected"} = params) do
    conn
    |> put_session(:user_return_to, ~p"/users/settings")
    |> create_with_message(params, "GitHub account connected successfully!")
  end

  def create(conn, %{"user" => user_params}) do
    create_with_message(conn, %{"user" => user_params}, "Welcome back!")
  end

  defp create_with_message(conn, %{"user" => user_params}, info) do
    %{"email" => email, "password" => password} = user_params

    case Accounts.Auth.authenticate_user(email, password) do
      {:ok, user} ->
        conn
        |> put_flash(:info, info)
        |> UserAuth.log_in_user(user, user_params)

      {:error, _reason} ->
        conn
        |> put_flash(:error, "Invalid email or password")
        |> put_flash(:email, String.slice(email, 0, 160))
        |> redirect(to: ~p"/users/log_in")
    end
  end

  def delete(conn, _params) do
    conn
    |> put_flash(:info, "Logged out successfully.")
    |> UserAuth.log_out_user()
  end
end
