defmodule ResolvinatorWeb.UserSessionController do
  use ResolvinatorWeb, :controller

  alias Resolvinator.Accounts
  alias ResolvinatorWeb.UserAuth

  def create(conn, %{"_action" => "registered"} = params) do
    create_with_message(conn, params, "Account created successfully!")
  end

  def create(conn, %{"_action" => "password_updated"} = params) do
    conn
    |> put_session(:user_return_to, ~p"/users/settings")
    |> create_with_message(params, "Password updated successfully!")
  end

  def create(conn, %{"user" => user_params}) do
    create_with_message(conn, %{"user" => user_params}, "Welcome back!")
  end

  defp create_with_message(conn, %{"user" => user_params}, info) do
    %{"email" => email, "password" => password} = user_params

    case Accounts.get_user_by_email_and_password(email, password) do
      %Accounts.User{} = user ->
        conn
        |> put_flash(:info, info)
        |> UserAuth.log_in_user(user, user_params)

      nil ->
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
