defmodule ResolvinatorWeb.GithubAuthController do
  use ResolvinatorWeb, :controller
  alias ResolvinatorWeb.GithubAuth

  def request(conn, _params) do
    GithubAuth.request(conn)
  end

  def callback(conn, _params) do
    GithubAuth.callback(conn)
  end
end
