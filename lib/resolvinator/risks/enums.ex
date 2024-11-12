defmodule Resolvinator.Risks.Enums do
  # Risk-related enums
  @risk_priorities [:low, :medium, :high, :critical]
  @risk_appetites [:averse, :minimal, :cautious, :flexible, :aggressive]
  @risk_statuses [:open, :in_progress, :mitigated, :accepted, :closed, :rejected, :archived]
  @risk_probabilities [:rare, :unlikely, :possible, :likely, :certain]

  # Impact-related enums
  @impact_severities [:negligible, :low, :medium, :high, :critical]
  @impact_areas [:financial, :operational, :reputational, :regulatory, :technical, :strategic, :functionality]
  @impact_timeframes [:immediate, :short_term, :medium_term, :long_term]

  # Relationship enums
  @relationship_types [:depends_on, :blocks, :relates_to]

  # Resource types
  @resource_types [:financial, :human, :material, :technical, :time, :information, :other]

  # Value mappings
  @severity_values %{
    low: 1,
    medium: 2,
    high: 3,
    critical: 4
  }

  @priority_values %{
    low: 1,
    medium: 2,
    high: 3,
    critical: 4
  }

  # Valid status transitions
  @valid_status_transitions %{
    open: %{
      in_progress: "Risk mitigation started",
      accepted: "Risk accepted without mitigation"
    },
    in_progress: %{
      mitigated: "Risk successfully mitigated",
      accepted: "Risk accepted during mitigation"
    },
    mitigated: %{
      closed: "Risk fully mitigated and verified"
    },
    accepted: %{
      closed: "Accepted risk now closed"
    },
    closed: %{}
  }

  # Mitigation statuses
  @mitigation_statuses [:not_started, :in_progress, :completed]

  # Getters
  def risk_priorities, do: @risk_priorities
  def risk_appetites, do: @risk_appetites
  def risk_statuses, do: @risk_statuses
  def risk_probabilities, do: @risk_probabilities
  def impact_severities, do: @impact_severities
  def impact_areas, do: @impact_areas
  def impact_timeframes, do: @impact_timeframes
  def relationship_types, do: @relationship_types
  def resource_types, do: @resource_types

  # Value mapping getters
  def severity_values, do: @severity_values
  def priority_values, do: @priority_values
  def valid_status_transitions, do: @valid_status_transitions

  # Mitigation statuses getters
  def mitigation_statuses, do: @mitigation_statuses

  # Validation helpers
  def valid_risk_priority?(priority) when priority in @risk_priorities, do: true
  def valid_risk_priority?(_), do: false

  def valid_risk_appetite?(appetite) when appetite in @risk_appetites, do: true
  def valid_risk_appetite?(_), do: false

  def valid_risk_status?(status) when status in @risk_statuses, do: true
  def valid_risk_status?(_), do: false

  def valid_risk_probability?(probability) when probability in @risk_probabilities, do: true
  def valid_risk_probability?(_), do: false

  def valid_impact_severity?(severity) when severity in @impact_severities, do: true
  def valid_impact_severity?(_), do: false

  def valid_impact_area?(area) when area in @impact_areas, do: true
  def valid_impact_area?(_), do: false

  def valid_impact_timeframe?(timeframe) when timeframe in @impact_timeframes, do: true
  def valid_impact_timeframe?(_), do: false

  def valid_relationship_type?(type) when type in @relationship_types, do: true
  def valid_relationship_type?(_), do: false

  def valid_resource_type?(type) when type in @resource_types, do: true
  def valid_resource_type?(_), do: false

  def valid_mitigation_status?(status) when status in @mitigation_statuses, do: true
  def valid_mitigation_status?(_), do: false

  @doc """
  Checks if a status transition is valid and returns the transition message if it is
  """
  def valid_status_transition?(from, to) do
    case get_in(@valid_status_transitions, [from, to]) do
      nil -> {:error, "Invalid status transition"}
      message -> {:ok, message}
    end
  end
end 