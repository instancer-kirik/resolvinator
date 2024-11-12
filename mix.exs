defmodule Resolvinator.MixProject do
  use Mix.Project

  def project do
    [
      app: :resolvinator,
      version: "0.1.0",
      elixir: "~> 1.14",
      elixirc_paths: elixirc_paths(Mix.env()),
      start_permanent: Mix.env() == :prod,
      aliases: aliases(),
      deps: deps()
    ]
  end

  def application do
    [
      mod: {Resolvinator.Application, []},
      extra_applications: [:logger, :runtime_tools, :os_mon]
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  # Specifies your project dependencies.
  #
  # Type `mix help deps` for examples and options.
  defp deps do
    [
      # Core Phoenix
      {:phoenix, "~> 1.7.12"},
      {:phoenix_ecto, "~> 4.4"},
      {:ecto_sql, "~> 3.10"},
      {:postgrex, ">= 0.0.0"},
      {:phoenix_html, "~> 4.0"},
      {:phoenix_live_view, "~> 1.0.0-rc.6"},
      {:phoenix_live_dashboard, "~> 0.8.3"},
      {:bandit, "~> 1.2"},

      # Development
      {:phoenix_live_reload, "~> 1.2", only: :dev},
      {:esbuild, "~> 0.8", runtime: Mix.env() == :dev},
      {:tailwind, "~> 0.2", runtime: Mix.env() == :dev},

      # Auth & Security
      {:pbkdf2_elixir, "~> 2.0"},
      {:assent, "~> 0.2.9"},
      {:cors_plug, "~> 3.0"},

      # API
      {:open_api_spex, "~> 3.16"},
      {:jason, "~> 1.2"},

      # Caching
      {:cachex, "~> 3.6"},
      {:hammer, "~> 6.1"},

      # Email
      {:swoosh, "~> 1.5"},
      {:finch, "~> 0.13"},

      # Monitoring
      {:telemetry_metrics, "~> 1.0.0"},
      {:telemetry_poller, "~> 1.1.0"},

      # Utilities
      {:gettext, "~> 0.20"},
      {:dns_cluster, "~> 0.1.1"},
      {:flint, "~> 0.4"},

      # Assets
      {:heroicons,
       github: "tailwindlabs/heroicons",
       tag: "v2.1.1",
       sparse: "optimized",
       app: false,
       compile: false,
       depth: 1},

      # Testing
      {:floki, ">= 0.30.0", only: :test},
      # Analysis (dev/test only)
      {:kino, "~> 0.13.0", only: [:dev, :test], runtime: false},
      {:vega_lite, "~> 0.1.8", only: [:dev, :test], runtime: false},
      {:explorer, "~> 0.8.0", only: [:dev, :test], runtime: false},
      {:nx, "~> 0.7.0", only: [:dev, :test], runtime: false},
      {:flame, "~> 0.3.0", only: [:dev, :test], runtime: false},
      {:mogrify, "~> 0.9.3"},
      {:guardian, "~> 2.3"},
      {:corsica, "~> 2.1"},
      {:httpoison, "~> 2.0"},
    ]
  end

  defp aliases do
    [
      setup: ["deps.get", "ecto.setup", "assets.setup", "assets.build", "copy_katex_fonts"],
      "ecto.setup": ["ecto.create", "ecto.migrate", "run priv/repo/seeds.exs"],
      "ecto.reset": ["ecto.drop", "ecto.setup"],
      test: ["ecto.create --quiet", "ecto.migrate --quiet", "test"],
      "assets.setup": ["tailwind.install --if-missing", "esbuild.install --if-missing"],
      "assets.build": ["tailwind resolvinator", "esbuild resolvinator"],
      "assets.deploy": [
        "tailwind resolvinator --minify",
        "esbuild resolvinator --minify",
        "phx.digest"
      ]
    ]
  end
end
