defmodule ResolvinatorWeb.API.AnalyticsController do
  use ResolvinatorWeb, :controller

  def risk_metrics(conn, params) do
    with {:ok, metrics} <- Resolvinator.Analytics.calculate_risk_metrics(params) do
      json(conn, %{data: metrics})
    end
  end

  def resource_utilization(conn, params) do
    with {:ok, utilization} <- Resolvinator.Analytics.resource_utilization(params) do
      json(conn, %{data: utilization})
    end
  end
end
