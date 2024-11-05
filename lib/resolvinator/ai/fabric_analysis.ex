defmodule Resolvinator.AI.FabricAnalysis do
  @moduledoc """
  Handles risk analysis using Microsoft Fabric's AI capabilities.
  """

  def analyze_risk(risk) do
    context = build_risk_context(risk)

    prompt = """
    Analyze this risk and provide:
    1. Key risk factors and their implications
    2. Recommended mitigation strategies
    3. Similar historical patterns or cases
    4. Implementation considerations
    5. Suggested next steps

    Risk Context:
    #{context}
    """

    case query_fabric_ai(prompt) do
      {:ok, response} -> {:ok, format_markdown(response)}
      error -> error
    end
  end

  def get_risk_advice(risk, question) do
    context = build_risk_context(risk)

    prompt = """
    Given this risk context:
    #{context}

    Please answer this question:
    #{question}
    """

    case query_fabric_ai(prompt) do
      {:ok, response} -> {:ok, format_markdown(response)}
      error -> error
    end
  end

  defp build_risk_context(risk) do
    """
    Name: #{risk.name}
    Description: #{risk.description}
    Probability: #{risk.probability}
    Impact: #{risk.impact}
    Priority: #{risk.priority}
    Status: #{risk.status}
    Mitigation Status: #{risk.mitigation_status}
    """
  end

  defp query_fabric_ai(prompt) do
    # Implementation of Microsoft Fabric API call
    # This is a placeholder - implement actual API call
    {:ok, "AI analysis response..."}
  end

  defp format_markdown(text) do
    # Convert AI response to HTML-safe markdown
    # You might want to use a markdown parser here
    text
  end
end
