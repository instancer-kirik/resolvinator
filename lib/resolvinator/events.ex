defmodule Resolvinator.Events do
  @moduledoc """
  Context for managing event occurrences and their analysis.
  """

  import Ecto.Query
  alias Resolvinator.Repo
  alias Resolvinator.Events.Event
  alias Resolvinator.AI.FabricAnalysis

  def list_events(project_id, opts \\ []) do
    Event
    |> where([e], e.project_id == ^project_id)
    |> apply_filters(opts[:filters])
    |> apply_sorting(opts[:sort])
    |> preload(opts[:preload] || [])
    |> Repo.paginate(opts[:page] || %{})
  end

  def get_event!(id, opts \\ []) do
    Event
    |> preload(opts[:preload] || [])
    |> Repo.get!(id)
  end

  def create_event(attrs \\ %{}) do
    %Event{}
    |> Event.changeset(attrs)
    |> Repo.insert()
    |> maybe_analyze_event()
    |> broadcast_event(:event_created)
  end

  def update_event(%Event{} = event, attrs) do
    event
    |> Event.changeset(attrs)
    |> Repo.update()
    |> broadcast_event(:event_updated)
  end

  def delete_event(%Event{} = event) do
    Repo.delete(event)
    |> broadcast_event(:event_deleted)
  end

  def analyze_event(%Event{} = event) do
    with {:ok, analysis} <- FabricAnalysis.analyze_event(event),
         {:ok, event} <- update_event(event, %{
           metadata: Map.put(event.metadata || %{}, "ai_analysis", analysis)
         }) do
      {:ok, event}
    end
  end

  def get_related_events(%Event{} = event) do
    Event
    |> where([e], e.risk_id == ^event.risk_id)
    |> or_where([e], e.mitigation_id == ^event.mitigation_id)
    |> or_where([e], e.impact_id == ^event.impact_id)
    |> where([e], e.id != ^event.id)
    |> Repo.all()
  end

  defp maybe_analyze_event({:ok, event} = result) do
    Task.start(fn -> analyze_event(event) end)
    result
  end
  defp maybe_analyze_event(error), do: error

  defp broadcast_event({:ok, event} = result, event_type) do
    Phoenix.PubSub.broadcast(
      Resolvinator.PubSub,
      "events:#{event.project_id}",
      {event_type, event}
    )
    result
  end
  defp broadcast_event(error, _), do: error

  defp apply_filters(query, nil), do: query
  defp apply_filters(query, filters) do
    Enum.reduce(filters, query, fn
      {"type", type}, query ->
        where(query, [e], e.event_type == ^type)
      {"severity", severity}, query ->
        where(query, [e], e.severity == ^severity)
      {"from_date", date}, query ->
        where(query, [e], e.occurred_at >= ^date)
      {"to_date", date}, query ->
        where(query, [e], e.occurred_at <= ^date)
      _, query -> query
    end)
  end

  defp apply_sorting(query, nil), do: order_by(query, [e], desc: e.occurred_at)
  defp apply_sorting(query, sort_params) do
    Enum.reduce(sort_params, query, fn
      {"occurred_at", "asc"}, query -> order_by(query, [e], asc: e.occurred_at)
      {"occurred_at", "desc"}, query -> order_by(query, [e], desc: e.occurred_at)
      {"severity", "asc"}, query -> order_by(query, [e], asc: e.severity)
      {"severity", "desc"}, query -> order_by(query, [e], desc: e.severity)
      _, query -> query
    end)
  end
end
