defmodule ResolvinatorWeb.PageController do
  use ResolvinatorWeb, :controller

  def home(conn, _params) do
    conn
    |> assign(:show_secondary_nav, false)
    |> assign(:layout, false)
    |> render(:home)
  end
end
