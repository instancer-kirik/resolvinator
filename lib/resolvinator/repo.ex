defmodule Resolvinator.Repo do
  use Ecto.Repo,
    otp_app: :resolvinator,
    adapter: Ecto.Adapters.Postgres
end
