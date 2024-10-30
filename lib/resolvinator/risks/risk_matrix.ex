defmodule Resolvinator.Risks.RiskMatrix do
  @moduledoc """
  Handles risk matrix calculations and visualizations.
  """

  @doc """
  Calculates the risk score based on probability and impact.
  Returns a tuple with {score, priority_level}
  """
  def calculate_risk_score(project, probability, impact) do
    score = Resolvinator.Projects.Project.risk_score(project, probability, impact)
    {score, determine_priority(score)}
  end

  @doc """
  Determines the priority level based on the risk score
  """
  def determine_priority(score) when is_integer(score) do
    cond do
      score >= 20 -> "critical"
      score >= 12 -> "high"
      score >= 8  -> "medium"
      true        -> "low"
    end
  end

  @doc """
  Returns a map representing the risk matrix with all possible combinations
  """
  def generate_matrix(project) do
    for probability <- ~w(rare unlikely possible likely certain),
        impact <- ~w(negligible minor moderate major severe),
        into: %{} do
      {score, priority} = calculate_risk_score(project, probability, impact)
      key = {probability, impact}
      {key, %{score: score, priority: priority}}
    end
  end

  @doc """
  Groups risks by their position in the risk matrix
  """
  def group_risks_by_matrix(risks, project) do
    risks
    |> Enum.group_by(fn risk -> 
      {risk.probability, risk.impact}
    end)
    |> Map.new(fn {key, risks} -> 
      {score, priority} = calculate_risk_score(project, elem(key, 0), elem(key, 1))
      {key, %{risks: risks, score: score, priority: priority}}
    end)
  end

  @doc """
  Returns risks that exceed the project's risk threshold
  """
  def high_priority_risks(risks, project) do
    threshold = Resolvinator.Projects.Project.risk_threshold(project)
    
    Enum.filter(risks, fn risk ->
      {score, _} = calculate_risk_score(project, risk.probability, risk.impact)
      score >= threshold
    end)
  end

  @doc """
  Returns risks that need review based on the project's review period
  """
  def risks_needing_review(risks, project) do
    Enum.filter(risks, fn risk ->
      Resolvinator.Projects.Project.needs_review?(project, risk)
    end)
  end
end 