defmodule ResolvinatorWeb.UserSocket do
  use Phoenix.Socket

  channel "project:*", ResolvinatorWeb.ProjectChannel

  @impl true
  def connect(%{"token" => token}, socket, _connect_info) do
    case Resolvinator.Accounts.verify_user_token(token) do
      {:ok, user_id} ->
        {:ok, assign(socket, :user_id, user_id)}
      {:error, _} ->
        :error
    end
  end

  @impl true
  def id(socket), do: "user_socket:#{socket.assigns.user_id}"
end 