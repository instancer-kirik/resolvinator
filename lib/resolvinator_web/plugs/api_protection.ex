defmodule ResolvinatorWeb.Plugs.APIProtection do
  import Plug.Conn
  import Phoenix.Controller
  import Logger

  @allowed_origins [
    "http://localhost:4000",
    "http://localhost:3000"
    # Add your production origins here
  ]

  def verify_origin(conn, _opts) do
    case get_req_header(conn, "origin") do
      [origin] when origin in @allowed_origins ->
        conn
      _ ->
        conn
        |> put_status(:forbidden)
        |> json(%{error: "Invalid origin"})
        |> halt()
    end
  end

  def rate_limit(conn, _opts) do
    case check_rate_limit(conn) do
      :ok -> conn
      :exceeded ->
        conn
        |> put_status(:too_many_requests)
        |> json(%{error: "Rate limit exceeded"})
        |> halt()
    end
  end

  def log_request(conn, _opts) do
    start_time = System.monotonic_time()

    register_before_send(conn, fn conn ->
      stop_time = System.monotonic_time()
      duration = System.convert_time_unit(stop_time - start_time, :native, :millisecond)

      Logger.info(
        "API Request: #{conn.method} #{conn.request_path} - Status: #{conn.status} - Duration: #{duration}ms"
      )

      conn
    end)
  end

  defp check_rate_limit(_conn) do
    # Implement your rate limiting logic here
    # This is a placeholder that always returns :ok
    :ok
  end
end 