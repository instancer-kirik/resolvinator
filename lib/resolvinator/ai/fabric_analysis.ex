defmodule Resolvinator.AI.FabricAnalysis do
  @moduledoc """
  Handles risk analysis using Microsoft Power BI/Fabric's AI capabilities.
  """
  
  require Logger
  alias Resolvinator.AI.FabricClient
  alias Resolvinator.Content

  def analyze_risk(risk) do
    # First, ensure we have access to Power BI
    with {:ok, workspaces} <- FabricClient.list_workspaces(),
         workspace_id <- find_analysis_workspace(workspaces),
         {:ok, datasets} <- FabricClient.list_datasets(workspace_id) do
      
      # Build the analysis context
      context = build_risk_context(risk)
      
      # Log the analysis attempt
      Logger.info("Analyzing risk: #{risk.id} using Power BI workspace: #{workspace_id}")
      
      # Here you would typically:
      # 1. Find or create appropriate dataset
      # 2. Push risk data to Power BI
      # 3. Run analysis
      # 4. Get results
      
      {:ok, %{
        workspace_id: workspace_id,
        datasets: datasets,
        context: context,
        analysis: "Analysis results will go here once implemented"
      }}
    else
      {:error, reason} ->
        Logger.error("Failed to analyze risk: #{inspect(reason)}")
        {:error, "Failed to perform risk analysis"}
    end
  end

  def get_risk_advice(risk, question) do
    # Similar pattern as analyze_risk
    with {:ok, workspaces} <- FabricClient.list_workspaces(),
         workspace_id <- find_analysis_workspace(workspaces) do
      
      context = build_risk_context(risk)
      
      Logger.info("Getting risk advice for: #{risk.id}, Question: #{question}")
      
      # Here you would:
      # 1. Use appropriate Power BI report/dataset
      # 2. Query based on context and question
      # 3. Format response
      
      {:ok, "Risk advice will be implemented here"}
    else
      {:error, reason} ->
        Logger.error("Failed to get risk advice: #{inspect(reason)}")
        {:error, "Failed to get risk advice"}
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

  defp find_analysis_workspace(workspaces) do
    # Find the workspace you want to use for analysis
    # You might want to configure this workspace ID in your config
    case Enum.find(workspaces["value"], & &1["name"] == "Risk Analysis") do
      nil -> 
        Logger.warn("Analysis workspace not found, using first available workspace")
        hd(workspaces["value"])["id"]
      workspace -> 
        workspace["id"]
    end
  end

  defp format_markdown(text) do
    # You might want to use a markdown parser here
    # For example, using Earmark:
    case Earmark.as_html(text) do
      {:ok, html, _} -> html
      {:error, _} -> text
    end
  end

  def analyze_query(query) do
    # Get relevant context from your data
    problems = Content.list_problems()
    solutions = Content.list_solutions()
    risks = Content.list_risks()
    
    context = """
    Available data:
    Problems: #{Enum.map(problems, & &1.name) |> Enum.join(", ")}
    Solutions: #{Enum.map(solutions, & &1.name) |> Enum.join(", ")}
    Risks: #{Enum.map(risks, & &1.name) |> Enum.join(", ")}
    """

    prompt = """
    You are an AI assistant for the Resolvinator application. You help users understand and work with their data.
    
    Context about available data:
    #{context}

    User query: #{query}

    Please provide a helpful response based on the available data and context.
    """

    case FabricClient.chat(prompt) do
      {:ok, response} -> response
      {:error, _} -> "I apologize, but I'm having trouble processing your request right now. Please try again later."
    end
  end
end
