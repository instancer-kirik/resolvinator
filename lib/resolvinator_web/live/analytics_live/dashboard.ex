defmodule ResolvinatorWeb.AnalyticsLive.Dashboard do
  use ResolvinatorWeb, :live_view
  alias Resolvinator.Analytics

  @impl true
  def mount(_params, _session, socket) do
    if connected?(socket) do
      :timer.send_interval(30000, self(), :update_metrics)
    end

    metrics = Analytics.get_dashboard_metrics()
    {:ok, assign(socket, metrics: metrics)}
  end

  @impl true
  def handle_info(:update_metrics, socket) do
    metrics = Analytics.get_dashboard_metrics()
    {:noreply, assign(socket, metrics: metrics)}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="analytics-dashboard">
      <.live_component
        module={ResolvinatorWeb.AnalyticsLive.RiskMetricsComponent}
        id="risk-metrics"
        metrics={@metrics.risks}
      />

      <.live_component
        module={ResolvinatorWeb.AnalyticsLive.ResourceUtilizationComponent}
        id="resource-utilization"
        metrics={@metrics.resources}
      />
    </div>
    """
  end
end
