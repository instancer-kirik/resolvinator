defmodule Resolvinator.Fabric.RiskAnalysis do
  @moduledoc """
  Handles risk analysis using Microsoft Fabric's Synapse Analytics
  """

  alias Resolvinator.Content.Problem
  alias Resolvinator.Risks.Risk

  def analyze_similar_risks(problem = %Problem{}) do
    query = """
    SELECT r.name, r.description, r.impact_level, r.probability,
           similarity_score(r.embedding, @problem_embedding) as similarity
    FROM risk_embeddings r
    WHERE similarity_score(r.embedding, @problem_embedding) > 0.75
    ORDER BY similarity DESC
    LIMIT 5
    """

    params = %{
      problem_embedding: generate_embedding(problem.description)
    }

    case query_synapse(query, params) do
      {:ok, results} -> format_risk_suggestions(results)
      {:error, _} -> default_risk_suggestions()
    end
  end

  def get_historical_mitigations(risk = %Risk{}) do
    query = """
    SELECT m.action_taken, m.effectiveness_score, m.implementation_cost
    FROM historical_mitigations m
    JOIN risk_categories c ON m.category_id = c.id
    WHERE c.name = @risk_category
    AND m.effectiveness_score > 7
    ORDER BY m.effectiveness_score DESC
    LIMIT 3
    """

    params = %{
      risk_category: risk.category
    }

    case query_synapse(query, params) do
      {:ok, results} -> format_mitigation_suggestions(results)
      {:error, _} -> default_mitigation_suggestions()
    end
  end

  # Private functions
  defp generate_embedding(text) do
    # This would typically use an ML model to generate embeddings
    # For demo purposes, we'll return a simple hash
    :crypto.hash(:sha256, text)
    |> Base.encode64()
  end

  defp query_synapse(query, params) do
    headers = [
      {"Authorization", "Bearer " <> get_fabric_token()},
      {"Content-Type", "application/json"}
    ]
    
    body = Jason.encode!(%{
      query: query,
      parameters: params,
      workspace_id: workspace_id()
    })

    case Req.post(synapse_endpoint(), headers: headers, body: body) do
      {:ok, %{status: 200, body: body}} -> {:ok, Jason.decode!(body)}
      error -> {:error, error}
    end
  end

  defp get_fabric_token do
    System.get_env("FABRIC_TOKEN")
  end

  defp workspace_id, do: System.get_env("FABRIC_WORKSPACE_ID")
  
  defp synapse_endpoint do
    workspace = System.get_env("FABRIC_WORKSPACE")
    "https://#{workspace}.fabric.microsoft.com/synapse/query"
  end

  defp format_risk_suggestions(results) do
    %{
      similar_events: Enum.map_join(results, "\n- ", & &1["name"]),
      risk_assessment: "Based on historical data, similar risks had: \n" <>
        Enum.map_join(results, "\n- ", &"#{&1["impact_level"]} impact (#{&1["probability"]} probability)"),
      recommended_actions: "Consider the following actions:\n" <>
        Enum.map_join(results, "\n- ", &"Review #{&1["name"]}"),
      prevention_measures: "Preventive measures from similar cases:\n" <>
        Enum.map_join(results, "\n- ", &"Monitor #{&1["name"]}")
    }
  end

  defp format_mitigation_suggestions(results) do
    %{
      recommended_actions: Enum.map_join(results, "\n- ", & &1["action_taken"]),
      effectiveness: Enum.map_join(results, "\n- ", &"#{&1["effectiveness_score"]}/10"),
      cost_estimate: Enum.map_join(results, "\n- ", & &1["implementation_cost"])
    }
  end

  defp default_risk_suggestions do
    %{
      similar_events: "No similar historical events found",
      risk_assessment: "Insufficient data for risk assessment",
      recommended_actions: "No specific recommendations available",
      prevention_measures: "No prevention measures suggested"
    }
  end

  defp default_mitigation_suggestions do
    %{
      recommended_actions: "No historical mitigation actions found",
      effectiveness: "No effectiveness data available",
      cost_estimate: "No cost estimates available"
    }
  end
end 