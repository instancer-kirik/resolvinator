defmodule ResolvinatorWeb.Plugs.RateLimiter do
  import Plug.Conn
  import Phoenix.Controller
  
  @rate_limit 100
  @time_window :timer.minutes(1)

  def init(opts) do
    setup_rate_limiter()
    opts
  end

  def call(conn, _opts) do
    case check_rate_limit(conn) do
      :ok -> conn
      :exceeded ->
        conn
        |> put_status(:too_many_requests)
        |> json(%{error: "Rate limit exceeded"})
        |> halt()
    end
  end

  defp check_rate_limit(conn) do
    client_ip = get_peer_data(conn).address |> Tuple.to_list() |> Enum.join(".")
    current_time = :os.system_time(:millisecond)

    case :ets.lookup(:rate_limiter_table, client_ip) do
      [{^client_ip, count, timestamp}] when current_time - timestamp < @time_window ->
        if count < @rate_limit do
          :ets.update_element(:rate_limiter_table, client_ip, {2, count + 1})
          :ok
        else
          :exceeded
        end

      _ ->
        :ets.insert(:rate_limiter_table, {client_ip, 1, current_time})
        :ok
    end
  end

  defp setup_rate_limiter do
    :ets.new(:rate_limiter_table, [:named_table, :public, :set, {:read_concurrency, true}])
  end
end 