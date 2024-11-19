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
      {:phoenix_ecto, "~> 4.6.3"},
      {:ecto_sql, "~> 3.10"},
      {:postgrex, ">= 0.0.0"},
      {:phoenix_html, "~> 4.0"},
      {:phoenix_live_view, "~> 1.0.0-rc.6"},
      {:phoenix_live_dashboard, "~> 0.8.3"},
      {:bandit, "~> 1.6.0"},

      # Development
      {:phoenix_live_reload, "~> 1.2", only: :dev},
      {:esbuild, "~> 0.8", runtime: Mix.env() == :dev},
      {:tailwind, "~> 0.2", runtime: Mix.env() == :dev},

      # Auth & Security
      {:pbkdf2_elixir, "~> 2.0"},
      {:assent, "~> 0.2.9"},
      {:cors_plug, "~> 3.0"},

      # Crypto & Money
      {:ex_money, "~> 5.15"},
      {:decimal, "~> 2.1"},
      {:httpoison, "~> 2.0"},

      # API
      {:open_api_spex, "~> 3.16"},
      {:jason, "~> 1.4"},

      # Caching & Performance
      {:cachex, "~> 3.6"},
      {:hammer, "~> 6.1"},

      # Email
      {:swoosh, "~> 1.17.3"},
      {:finch, "~> 0.16"},

      # Monitoring
      {:telemetry_metrics, "~> 1.0"},
      {:telemetry_poller, "~> 1.1"},

      # Utilities
      {:gettext, "~> 0.26.2"},
      {:dns_cluster, "~> 0.1.1"},
      {:flint, "~> 0.5.1"},
      {:castore, "~> 1.0.10"},
      {:plug_cowboy, "~> 2.5"},
      {:tentacat, "~> 2.2"},
      {:git_cli, "~> 0.3"},

      {:deepscape, in_umbrella: true},

      # Assets
      {:heroicons,
       github: "tailwindlabs/heroicons",
       tag: "v2.1.1",
       sparse: "optimized",
       app: false,
       compile: false,
       depth: 1},

      # ML & NLP Stack
      {:langchain, "~> 0.1.0"},
      {:req, "~> 0.5.7"},
      {:openai, "~> 0.5.2"},
      {:ollama, "~> 0.1"},

      # Testing & Analysis
      {:floki, ">= 0.30.0", only: :test},
      {:kino, "~> 0.13.0", only: [:dev, :test], runtime: false},
      {:vega_lite, "~> 0.1.11", only: [:dev, :test], runtime: false},
      {:explorer, "~> 0.8.0", only: [:dev, :test], runtime: false},
      {:nx, "~> 0.7.0", only: [:dev, :test], runtime: false},
      {:flame, "~> 0.3.0", only: [:dev, :test], runtime: false},
      {:mogrify, "~> 0.9.3"},
      {:guardian, "~> 2.3"},
      {:corsica, "~> 2.1"}
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
