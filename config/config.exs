# This file is responsible for configuring your application
# and its dependencies with the aid of the Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
import Config

config :resolvinator,
  ecto_repos: [Resolvinator.Repo],
  generators: [timestamp_type: :utc_datetime],
  cache_ttl: :timer.minutes(5),
  fabric_endpoint: System.get_env("FABRIC_API_ENDPOINT"),
  fabric_key: System.get_env("FABRIC_API_KEY"),
  azure_tenant_id: System.get_env("AZURE_TENANT_ID"),
  azure_client_id: "3e888816-33ad-4839-9bc9-5b5f57a425ec",
  azure_client_secret: System.get_env("AZURE_CLIENT_SECRET")

# Configures the endpoint
config :resolvinator, ResolvinatorWeb.Endpoint,
  url: [host: "localhost"],
  adapter: Bandit.PhoenixAdapter,
  render_errors: [
    formats: [html: ResolvinatorWeb.ErrorHTML, json: ResolvinatorWeb.ErrorJSON],
    layout: false
  ],
  pubsub_server: Resolvinator.PubSub,
  live_view: [signing_salt: "UZNKtQmW"]

# Configures the mailer
#
# By default it uses the "Local" adapter which stores the emails
# locally. You can see the emails in your browser, at "/dev/mailbox".
#
# For production it's recommended to configure a different adapter
# at the `config/runtime.exs`.
config :resolvinator, Resolvinator.Mailer, adapter: Swoosh.Adapters.Local

# Configure esbuild (the version is required)
config :esbuild,
  version: "0.17.11",
  resolvinator: [
    args: ~w(
      js/app.js 
      --bundle 
      --target=es2017 
      --outdir=../priv/static/assets 
      --external:/fonts/* 
      --external:/images/* 
      --external:react 
      --external:react-dom 
      --external:react-router 
      --external:@react-three/fiber 
      --external:three 
      --loader:.js=jsx 
      --loader:.jsx=jsx
      --loader:.ttf=file
      --loader:.woff=file
      --loader:.woff2=file
      --public-path=/assets
      --asset-names=[name]-[hash]
    ),
    cd: Path.expand("../assets", __DIR__),
    env: %{"NODE_PATH" => Path.expand("../deps", __DIR__)}
  ]

# Add this configuration for handling CSS imports
config :esbuild,
  css: [
    args: ~w(css/app.css --bundle --outdir=../priv/static/assets),
    cd: Path.expand("../assets", __DIR__)
  ]

# Configure tailwind (the version is required)
config :tailwind,
  version: "3.4.0",
  resolvinator: [
    args: ~w(
      --config=tailwind.config.js
      --input=css/app.css
      --output=../priv/static/assets/app.css
    ),
    cd: Path.expand("../assets", __DIR__)
  ]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason
config :assent,
  http_adapter: {Assent.HTTPAdapter.Finch, supervisor: Resolvinator.Finch}

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"

# Add to your existing config:

config :hammer,
  backend: {Hammer.Backend.ETS, [expiry_ms: 60_000 * 60 * 4,
                                cleanup_interval_ms: 60_000 * 10]}

# Optional: Configure different rate limits for different environments
config :resolvinator, Resolvinator.Auth.RateLimiter,
  socket_connect_limit: 100,
  socket_connect_window_ms: 60_000,
  api_request_limit: 1000,
  api_request_window_ms: 60_000

# Livebook configuration
# config :livebook,
#   app_service_name: :resolvinator,
#   app_service_url: nil,
#   authentication_mode: :token,
#   default_runtime: {Livebook.Runtime.ElixirStandalone, []},
#   cookie: :resolvinator_cookie,
#   ip: {127, 0, 0, 1},
#   port: 8080

# # Separate configuration for Livebook.Apps
# config :livebook, Livebook.Apps,
#   retry_backoff_base_ms: 1000,
#   retry_backoff_max_ms: 30_000,
#   shutdown_backoff_ms: 5_000

# Guardian configuration
config :resolvinator, Resolvinator.Guardian,
  issuer: "resolvinator",
  secret_key: System.get_env("GUARDIAN_SECRET_KEY"),
  ttl: {30, :days},
  token_ttl: %{
    "access" => {2, :hours},
    "refresh" => {30, :days}
  }

config :resolvinator, Resolvinator.Repo,
  migration_primary_key: [type: :binary_id],
  migration_foreign_key: [type: :binary_id]
