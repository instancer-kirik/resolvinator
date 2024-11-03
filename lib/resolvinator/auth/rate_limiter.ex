defmodule Resolvinator.Auth.RateLimiter do
  @moduledoc """
  Rate limiting functionality using Hammer.
  """

  def check_rate(key, limit, window_ms) do
    case Hammer.check_rate(
      "socket:#{key}",
      window_ms,
      limit
    ) do
      {:allow, _count} -> :ok
      {:deny, _limit} -> :error
    end
  end
end
