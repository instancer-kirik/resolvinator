import Config

# Configure your database
config :resolvinator, Resolvinator.Repo,
  username: System.get_env("POSTGRES_USER", "postgres"),
  password: System.get_env("POSTGRES_PASSWORD", "root"),
  hostname: System.get_env("POSTGRES_HOST", "localhost"),
  database: System.get_env("POSTGRES_DB", "resolvinator_dev"),
  stacktrace: true,
  show_sensitive_data_on_connection_error: true,
  pool_size: 10

# For development, we disable any cache and enable
# debugging and code reloading.
#
# The watchers configuration can be used to run external
# watchers to your application. For example, we can use it
# to bundle .js and .css sources.
config :resolvinator, ResolvinatorWeb.Endpoint,
  # Binding to loopback ipv4 address prevents access from other machines.
  # Change to `ip: {0, 0, 0, 0}` to allow access from other machines.
  http: [ip: {127, 0, 0, 1}, port: 4000],
  check_origin: false,
  code_reloader: true,
  debug_errors: true,
  secret_key_base: "jD/UyN5rz+OxU705B+aPGTJjfeJNwB8rn/ZPXjPHjNBoiyk/IUSN5kJ+d77BgdKI",
  watchers: [
    esbuild: {Esbuild, :install_and_run, [:resolvinator, ~w(--sourcemap=inline --watch)]},
    tailwind: {Tailwind, :install_and_run, [:resolvinator, ~w(--watch)]}
  ]

# ## SSL Support
#
# In order to use HTTPS in development, a self-signed
# certificate can be generated by running the following
# Mix task:
#
#     mix phx.gen.cert
#
# Run `mix help phx.gen.cert` for more information.
#
# The `http:` config above can be replaced with:
#
#     https: [
#       port: 4001,
#       cipher_suite: :strong,
#       keyfile: "priv/cert/selfsigned_key.pem",
#       certfile: "priv/cert/selfsigned.pem"
#     ],
#
# If desired, both `http:` and `https:` keys can be
# configured to run both http and https servers on
# different ports.

# Watch static and templates for browser reloading.
config :resolvinator, ResolvinatorWeb.Endpoint,
  live_reload: [
    patterns: [
      ~r"priv/static/(?!uploads/).*(js|css|png|jpeg|jpg|gif|svg)$",
      ~r"priv/gettext/.*(po)$",
      ~r"lib/resolvinator_web/(controllers|live|components)/.*(ex|heex)$"
    ]
  ]

# Enable dev routes for dashboard and mailbox
config :resolvinator, dev_routes: true

# Do not include metadata nor timestamps in development logs
config :logger, :console, format: "[$level] $message\n"

# Set a higher stacktrace during development. Avoid configuring such
# in production as building large stacktraces may be expensive.
config :phoenix, :stacktrace_depth, 20

# Initialize plugs at runtime for faster development compilation
config :phoenix, :plug_init_mode, :runtime

config :phoenix_live_view,
  # Include HEEx debug annotations as HTML comments in rendered markup
  debug_heex_annotations: true,
  # Enable helpful, but potentially expensive runtime checks
  enable_expensive_runtime_checks: true

# Disable swoosh api client as it is only required for production adapters.
config :swoosh, :api_client, false

config :assent,
  github: [
    client_id: System.get_env("GITHUB_CLIENT_ID"),
    client_secret: System.get_env("GITHUB_CLIENT_SECRET"),
    redirect_uri: "http://localhost:4000/auth/github/callback",
  ]
#(Caution: in production you would pass these secret as env vars read in runtime.exs)

config :resolvinator,
  fabric_endpoint: System.get_env("FABRIC_API_ENDPOINT", "http://localhost:4000/api"),
  fabric_key: System.get_env("FABRIC_API_KEY"),
  azure_tenant_id: System.get_env("AZURE_TENANT_ID"),
  azure_client_id: System.get_env("AZURE_CLIENT_ID"),
  azure_client_secret: System.get_env("AZURE_CLIENT_SECRET"),
  enable_ai_validations: false  # Enable this only when you have proper Azure credentials
# config/dev.exs
config :resolvinator, Resolvinator.Rewards.CryptoReward,
  use_testnet: true,
  testnet_config: %{
    ethereum: System.get_env("ETHEREUM_TESTNET_RPC", "https://sepolia.infura.io/v3/#{System.get_env("INFURA_PROJECT_ID")}"),
    polygon: System.get_env("POLYGON_TESTNET_RPC", "https://rpc-mumbai.maticvigil.com"),
    solana: System.get_env("SOLANA_TESTNET_RPC", "https://api.devnet.solana.com"),
    bitcoin: System.get_env("BITCOIN_TESTNET_RPC", "https://testnet-api.smartbit.com.au/v1/blockchain")
  }
if File.exists?("config/dev.local.exs") do
  import_config "dev.local.exs"
end
