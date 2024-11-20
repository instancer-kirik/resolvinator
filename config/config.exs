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
  azure_client_id: System.get_env("AZURE_CLIENT_ID"),
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

# Exchange rate configuration
config :ex_money,
  exchange_rates_retrieve_every: :timer.minutes(5),
  api_module: Money.ExchangeRates.OpenExchangeRates,
  api_key: System.get_env("OPEN_EXCHANGE_RATES_API_KEY"),
  default_currency: "USD"

# Crypto reward configuration
config :resolvinator, Resolvinator.Rewards.CryptoReward,
  ethereum_rpc_url: System.get_env("ETHEREUM_RPC_URL"),
  polygon_rpc_url: System.get_env("POLYGON_RPC_URL"),
  solana_rpc_url: System.get_env("SOLANA_RPC_URL"),
  bitcoin_rpc_url: System.get_env("BITCOIN_RPC_URL"),
  default_gas_price: 20,
  default_gas_limit: 21000,
  blockchain_rate_limit: [
    window_ms: :timer.minutes(1),
    max_requests: 100
  ]

# Rate limiting configuration
config :hammer,
  backend: {Hammer.Backend.ETS, [
    expiry_ms: 60_000 * 60 * 4,
    cleanup_interval_ms: 60_000 * 10
  ]}

config :resolvinator, Resolvinator.Rewards.RateLimiter,
  crypto_transfer_limit: 50,
  crypto_transfer_window_ms: 60_000,
  token_mint_limit: 20,
  token_mint_window_ms: 300_000

# Crypto security configuration
config :resolvinator, Resolvinator.Rewards.CryptoSecurity,
  encryption_key: System.get_env("CRYPTO_ENCRYPTION_KEY"),
  required_signatures: 2,
  authorized_signers: System.get_env("AUTHORIZED_SIGNERS", "") |> String.split(","),
  max_transaction_value_usd: System.get_env("MAX_TRANSACTION_VALUE_USD", "10000") |> String.to_integer(),
  require_approval_above_usd: System.get_env("REQUIRE_APPROVAL_ABOVE_USD", "1000") |> String.to_integer()

# Monitoring configuration
config :resolvinator, Resolvinator.Monitoring,
  crypto_metrics: [
    transaction_count: [
      event_name: [:crypto, :transaction, :complete],
      measurement: :count,
      tags: [:blockchain, :token_type]
    ],
    transaction_value: [
      event_name: [:crypto, :transaction, :value],
      measurement: :sum,
      tags: [:currency]
    ],
    gas_costs: [
      event_name: [:crypto, :gas, :used],
      measurement: :sum,
      tags: [:blockchain]
    ]
  ]

# Guardian configuration
config :resolvinator, Resolvinator.Guardian,
  issuer: "resolvinator",
  secret_key: System.get_env("GUARDIAN_SECRET_KEY"),
  ttl: %{
    "access" => {1, :hour},
    "refresh" => {7, :days},
    "api" => {30, :days},
    "web3" => {1, :day}
  },
  token_ttl: %{
    "access" => {1, :hour},
    "refresh" => {7, :days},
    "api" => {30, :days},
    "web3" => {1, :day}
  },
  allowed_algos: ["HS512"],
  verify_module: Guardian.JWT,
  hooks: Resolvinator.Guardian

# Guardian DB configuration
config :guardian, Guardian.DB,
  repo: Resolvinator.Repo,
  schema_name: "guardian_tokens", # default
  sweep_interval: 60 # 60 minutes

# Plug security configuration
config :resolvinator, ResolvinatorWeb.Security.PlugAttack,
  storage: {PlugAttack.Storage.Ets, Resolvinator.Security.RateLimit.Storage},
  rules: [
    throttle: {
      # Max 1000 requests per 5 minutes per IP
      {"/api", 1000, 300_000},
      # Max 100 requests per minute for authentication endpoints
      {~r{/api/auth/.*}, 100, 60_000}
    }
  ]

# CORS configuration
config :cors_plug,
  origin: ["https://*.resolvinator.com"],
  max_age: 86400,
  methods: ["GET", "POST", "PUT", "PATCH", "DELETE", "OPTIONS"],
  headers: ["Authorization", "Content-Type", "Accept", "Origin", "User-Agent", "DNT","Cache-Control", "X-Mx-ReqToken", "Keep-Alive", "X-Requested-With", "If-Modified-Since", "X-CSRF-Token"]

# Web3 configuration
config :resolvinator, Resolvinator.Web3,
  ethereum_rpc: System.get_env("ETHEREUM_RPC_URL"),
  chain_id: System.get_env("ETHEREUM_CHAIN_ID", "1"),
  contract_addresses: %{
    token: System.get_env("TOKEN_CONTRACT_ADDRESS"),
    nft: System.get_env("NFT_CONTRACT_ADDRESS")
  }

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"

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

config :resolvinator, Resolvinator.Repo,
  migration_primary_key: [type: :binary_id],
  migration_foreign_key: [type: :binary_id]
