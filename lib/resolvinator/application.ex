defmodule Resolvinator.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      ResolvinatorWeb.Telemetry,
      Resolvinator.Repo,
      {DNSCluster, query: Application.get_env(:resolvinator, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: Resolvinator.PubSub},
      # Start the Finch HTTP client for sending emails
      {Finch, name: Resolvinator.Finch},
      # Start a worker by calling: Resolvinator.Worker.start_link(arg)
      # {Resolvinator.Worker, arg},
      # Start to serve requests, typically the last entry
      ResolvinatorWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Resolvinator.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    ResolvinatorWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
