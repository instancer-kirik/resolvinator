defmodule Resolvinator.MixProject do
  use Mix.Project

  def project do
    [
      app: :resolvinator,
      version: "0.1.0",
      build_path: "../../_build",
      config_path: "../../config/config.exs",
      deps_path: "../../deps",
      lockfile: "../../mix.lock",
      elixir: "~> 1.14",
      elixirc_paths: elixirc_paths(Mix.env()),
      start_permanent: Mix.env() == :prod,
      aliases: aliases(),
      deps: deps(),
      contexts: [
        resolvers: [
          path: "lib/resolvinator/resolvers",
          base_module: Resolvinator.Resolvers,
          patterns: ["**/*.ex"]
        ],
        projects: [
          path: "lib/resolvinator/projects",
          base_module: Resolvinator.Projects,
          patterns: ["**/*.ex"]
        ],
        shared: [
          path: "lib/resolvinator/shared",
          base_module: Resolvinator.Shared,
          patterns: ["**/*.ex"]
        ]
      ]
    ]
  end

  def application do
    [
      mod: {Resolvinator.Application, []},
      extra_applications: [:logger, :runtime_tools, :os_mon, :tzdata, :acts]
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  defp deps do
    [
      # Core Phoenix
      {:phoenix, "~> 1.7.12"},
      {:phoenix_ecto, "~> 4.6.3"},
      {:phoenix_html, "~> 4.0"},
      {:phoenix_live_reload, "~> 1.5", only: :dev},
      {:phoenix_live_view, "~> 0.20.17"},

      {:floki, ">= 0.30.0", only: :test},
      {:phoenix_live_dashboard, "~> 0.8.5"},
      {:esbuild, "~> 0.8", runtime: Mix.env() == :dev},
      {:tailwind, "~> 0.2.4", runtime: Mix.env() == :dev},
      {:telemetry_metrics, "~> 1.0"},
      {:telemetry_poller, "~> 1.0"},
      {:gettext, "~> 0.20"},
      {:jason, "~> 1.2"},
      {:plug_cowboy, "~> 2.7.2"},
      # Add missing dependencies
      {:guardian, "~> 2.3"},
      {:swoosh, "~> 1.14"},
      {:ranch, "~> 2.1.0", override: true},
      {:parse_trans, "~> 3.4.2", override: true},
      {:httpoison, "~> 2.0"},
      {:nx, "~> 0.9.2"},
      {:acts, in_umbrella: true},
      {:time_tracker, in_umbrella: true},
      {:tzdata, "~> 1.1.2"},

      # Database
      {:ecto_sql, "~> 3.10"},
      {:postgrex, ">= 0.0.0"},

      # Schema and behavior support
      {:flint, "~> 0.6.0"},

      # Umbrella dependencies
      {:blockchain_core, in_umbrella: true},
      {:blockchain_tokens, in_umbrella: true}
    ]
  end

  defp aliases do
    [
      setup: ["deps.get", "ecto.setup", "assets.setup", "assets.build"],
      "ecto.setup": ["ecto.create", "ecto.migrate", "run priv/repo/seeds.exs"],
      "ecto.reset": ["ecto.drop", "ecto.setup"],
      test: ["ecto.create --quiet", "ecto.migrate --quiet", "test"],
      "assets.setup": ["tailwind.install --if-missing", "esbuild.install --if-missing"],
      "assets.build": ["tailwind default", "esbuild default"],
      "assets.deploy": ["tailwind default --minify", "esbuild default --minify", "phx.digest"]
    ]
  end
end
