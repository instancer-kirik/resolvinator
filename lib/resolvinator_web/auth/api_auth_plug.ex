defmodule ResolvinatorWeb.APIAuthPlug do
  import Plug.Conn
  import Phoenix.Controller

  alias Acts

  def init(opts), do: opts

  def call(conn, _opts) do
    with ["Bearer " <> token] <- get_req_header(conn, "authorization"),
         {:ok, user} <- Acts.Auth.verify_user_token(token) do
      assign(conn, :current_user, user)
    else
      _ ->
        conn
        |> put_status(:unauthorized)
        |> json(%{error: "Unauthorized"})
        |> halt()
    end
  end
end
