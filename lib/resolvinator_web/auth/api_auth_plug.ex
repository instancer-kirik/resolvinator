defmodule ResolvinatorWeb.APIAuthPlug do
  import Plug.Conn
  import Phoenix.Controller

  def init(opts), do: opts

  def call(conn, _opts) do
    with ["Bearer " <> token] <- get_req_header(conn, "authorization"),
         {:ok, user} <- authenticate_token(token) do
      assign(conn, :current_user, user)
    else
      _ ->
        conn
        |> put_status(:unauthorized)
        |> json(%{error: "Unauthorized"})
        |> halt()
    end
  end

  defp authenticate_token(token) do
    # Implement your token verification logic here
    # For example, using Guardian or a similar library
    Resolvinator.Accounts.get_user_by_session_token(token)
  end
end 