defmodule Resolvinator.Analytics do
  import Ecto.Query
  alias Resolvinator.{Repo, Risks, Resources}

  def calculate_risk_metrics(params \\ %{}) do
    metrics = %{
      total_risks: count_risks(),
      risk_distribution: risk_distribution(),
      risk_trends: risk_trends(params),
      top_categories: top_risk_categories(),
      mitigation_effectiveness: calculate_mitigation_effectiveness()
    }

    {:ok, metrics}
  end

  def resource_utilization(params \\ %{}) do
    metrics = %{
      allocation_rate: calculate_allocation_rate(),
      resource_availability: check_resource_availability(),
      utilization_trends: resource_utilization_trends(params),
      cost_analysis: analyze_resource_costs(),
      capacity_planning: generate_capacity_forecast()
    }

    {:ok, metrics}
  end

  # Risk Analytics Functions
  defp count_risks do
    Repo.aggregate(Risks.Risk, :count)
  end

  defp risk_distribution do
    Risks.Risk
    |> group_by([r], r.severity)
    |> select([r], {r.severity, count(r.id)})
    |> Repo.all()
    |> Enum.into(%{})
  end

  defp risk_trends(params) do
    time_range = Map.get(params, :time_range, "30d")
    
    Risks.Risk
    |> where([r], r.inserted_at >= ^calculate_date_range(time_range))
    |> group_by([r], fragment("date_trunc('day', ?)", r.inserted_at))
    |> select([r], {fragment("date_trunc('day', ?)", r.inserted_at), count(r.id)})
    |> Repo.all()
    |> Enum.into(%{})
  end

  defp top_risk_categories do
    Risks.Risk
    |> join(:left, [r], c in assoc(r, :category))
    |> group_by([r, c], c.name)
    |> select([r, c], {c.name, count(r.id)})
    |> limit(5)
    |> Repo.all()
    |> Enum.into(%{})
  end

  defp calculate_mitigation_effectiveness do
    Risks.Risk
    |> join(:left, [r], m in assoc(r, :mitigations))
    |> group_by([r], r.id)
    |> select([r, m], {
      r.id,
      fragment("CASE WHEN COUNT(?) > 0 THEN AVG(?.effectiveness) ELSE 0 END", m.id, m)
    })
    |> Repo.all()
    |> Enum.reduce(%{total: 0, count: 0}, fn {_id, effectiveness}, acc ->
      %{total: acc.total + effectiveness, count: acc.count + 1}
    end)
    |> then(fn %{total: total, count: count} ->
      if count > 0, do: total / count, else: 0
    end)
  end

  # Resource Analytics Functions
  defp calculate_allocation_rate do
    Resources.Allocation
    |> where([a], not is_nil(a.resource_id))
    |> group_by([a], a.resource_id)
    |> select([a], {a.resource_id, count(a.id)})
    |> Repo.all()
    |> Enum.into(%{})
  end

  defp check_resource_availability do
    Resources.Resource
    |> where([r], r.status == "available")
    |> select([r], {r.type, count(r.id)})
    |> group_by([r], r.type)
    |> Repo.all()
    |> Enum.into(%{})
  end

  defp resource_utilization_trends(params) do
    time_range = Map.get(params, :time_range, "30d")

    Resources.Allocation
    |> where([a], a.inserted_at >= ^calculate_date_range(time_range))
    |> group_by([a], fragment("date_trunc('day', ?)", a.inserted_at))
    |> select([a], {
      fragment("date_trunc('day', ?)", a.inserted_at),
      count(a.id)
    })
    |> Repo.all()
    |> Enum.into(%{})
  end

  defp analyze_resource_costs do
    Resources.Resource
    |> join(:left, [r], a in assoc(r, :allocations))
    |> group_by([r], r.type)
    |> select([r, a], {
      r.type,
      %{
        total_cost: sum(r.cost),
        utilization_count: count(a.id)
      }
    })
    |> Repo.all()
    |> Enum.into(%{})
  end

  defp generate_capacity_forecast do
    current_utilization = check_resource_availability()
    allocation_trends = calculate_allocation_rate()

    # Simple linear projection based on current utilization and allocation trends
    current_utilization
    |> Map.keys()
    |> Enum.map(fn resource_type ->
      current = Map.get(current_utilization, resource_type, 0)
      trend = Map.get(allocation_trends, resource_type, 0)
      
      forecast = max(0, current - trend)
      {resource_type, forecast}
    end)
    |> Enum.into(%{})
  end

  # Helper Functions
  defp calculate_date_range("7d"), do: DateTime.utc_now() |> DateTime.add(-7, :day)
  defp calculate_date_range("30d"), do: DateTime.utc_now() |> DateTime.add(-30, :day)
  defp calculate_date_range("90d"), do: DateTime.utc_now() |> DateTime.add(-90, :day)
  defp calculate_date_range("1y"), do: DateTime.utc_now() |> DateTime.add(-365, :day)
  defp calculate_date_range(_), do: DateTime.utc_now() |> DateTime.add(-30, :day)
end
