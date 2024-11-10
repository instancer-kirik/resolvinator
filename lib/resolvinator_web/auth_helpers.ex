defmodule ResolvinatorWeb.AuthHelpers do
  import Plug.Conn
  import Phoenix.Controller
  use ResolvinatorWeb, :verified_routes

  def is_authenticated?(conn) do
    !!conn.assigns[:current_user]
  end

  def current_user(conn) do
    conn.assigns[:current_user]
  end

  def require_authenticated_user(conn, opts) do
    ResolvinatorWeb.UserAuth.require_authenticated_user(conn, opts)
  end
end 