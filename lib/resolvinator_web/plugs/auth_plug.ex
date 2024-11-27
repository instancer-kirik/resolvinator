defmodule ResolvinatorWeb.Plugs.AuthPlug do
  import Plug.Conn
  import Phoenix.Controller

  alias Acts.Auth

  def init(opts), do: opts

  def call(conn, _opts) do
    if user_token = get_session(conn, :user_token) do
      user = Auth.get_user_by_session_token(user_token)
      assign(conn, :current_user, user)
    else
      assign(conn, :current_user, nil)
    end
  end

  def require_authenticated_user(conn, _opts) do
    if conn.assigns[:current_user] do
      conn
    else
      conn
      |> put_flash(:error, "You must log in to access this page.")
      |> redirect(to: "/users/log_in")
      |> halt()
    end
  end

  def redirect_if_user_is_authenticated(conn, _opts) do
    if conn.assigns[:current_user] do
      conn
      |> redirect(to: "/")
      |> halt()
    else
      conn
    end
  end

  def require_role(conn, role) do
    user = conn.assigns[:current_user]

    if user && Auth.has_role?(user, [role]) do
      conn
    else
      conn
      |> put_flash(:error, "You are not authorized to access this page.")
      |> redirect(to: "/")
      |> halt()
    end
  end

  def api_auth(conn, _opts) do
    with ["Bearer " <> token] <- get_req_header(conn, "authorization"),
         {:ok, user} <- Auth.get_user_by_api_token(token) do
      assign(conn, :current_user, user)
    else
      _ ->
        conn
        |> put_status(:unauthorized)
        |> json(%{error: "Invalid or missing authentication token"})
        |> halt()
    end
  end
end
