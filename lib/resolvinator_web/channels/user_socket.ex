defmodule ResolvinatorWeb.UserSocket do
  use Phoenix.Socket
  require Logger

  # Channels
  channel "user:*", ResolvinatorWeb.UserChannel
  channel "project:*", ResolvinatorWeb.ProjectChannel
  channel "risks:*", ResolvinatorWeb.RiskChannel
  channel "events:*", ResolvinatorWeb.EventChannel
  channel "system:*", ResolvinatorWeb.SystemChannel

  # Socket params are passed from the client
  @impl true
  def connect(%{"token" => token, "client_version" => client_version} = params, socket, _connect_info) do
    with {:ok, claims} <- Resolvinator.Auth.verify_token(token),
         :ok <- verify_client_version(client_version),
         :ok <- check_rate_limit(claims.user_id) do

      socket = assign(socket,
        user_id: claims.user_id,
        client_version: client_version
      )

      # Log connection for security audit
      Logger.info("WebSocket connection established",
        user_id: claims.user_id,
        client_version: client_version,
        ip: get_in(params, ["connect_info", "ip"])
      )

      {:ok, socket}
    else
      {:error, :invalid_token} ->
        Logger.warning("WebSocket connection rejected: invalid token")
        :error
      {:error, :version_mismatch} ->
        Logger.warning("WebSocket connection rejected: incompatible client version")
        {:error, %{reason: "Client update required"}}
      {:error, :rate_limited} ->
        Logger.warning("WebSocket connection rejected: rate limited")
        {:error, %{reason: "Too many connection attempts"}}
    end
  end

  def connect(params, _socket, _connect_info) do
    Logger.warning("WebSocket connection rejected: missing parameters",
      params: inspect(params)
    )
    :error
  end

  # Rate limiting configuration
  @max_messages_per_minute 100
  @minimum_client_version "1.0.0"

  # Verify client version compatibility
  defp verify_client_version(version) when is_binary(version) do
    case Version.parse(version) do
      {:ok, client_version} ->
        case Version.compare(client_version, Version.parse!(@minimum_client_version)) do
          :lt -> {:error, :version_mismatch}
          _ -> :ok
        end
      :error ->
        {:error, :version_mismatch}
    end
  end
  defp verify_client_version(_), do: {:error, :version_mismatch}

  # Rate limiting check
  defp check_rate_limit(user_id) do
    Resolvinator.Auth.check_rate_limit(
      "socket_connect:#{user_id}",
      @max_messages_per_minute,
      60_000
    )
  end

  # Socket id for identifying target
  @impl true
  def id(socket), do: "user_socket:#{socket.assigns.user_id}"
end
