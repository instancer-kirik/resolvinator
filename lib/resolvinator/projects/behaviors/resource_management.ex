defmodule Resolvinator.Projects.Behaviors.ResourceManagement do
	@moduledoc """
	Defines the behavior for projects that need resource management capabilities.
	This includes tracking budgets, allocating resources, and managing assets.
	"""

	@doc """
	Returns whether resource management is enabled for this project
	"""
	@callback resource_management_enabled?() :: boolean()

	@doc """
	Returns the resource management settings
	"""
	@callback resource_settings() :: map()

	@doc """
	Returns the resource allocation strategy
	"""
	@callback allocation_strategy() :: atom()

	@doc """
	Validates resource management settings
	"""
	@callback validate_resource_settings(settings :: map()) :: :ok | {:error, String.t()}

	@optional_callbacks [
		resource_management_enabled?: 0,
		resource_settings: 0,
		allocation_strategy: 0,
		validate_resource_settings: 1
	]

	def default_resource_settings do
		%{
			budget_tracking_enabled: true,
			resource_allocation_mode: "manual",
			resource_types: ["human", "financial", "material"],
			tracking_frequency: "weekly",
			alerts_enabled: %{
				budget_threshold: true,
				resource_conflicts: true,
				allocation_updates: true
			}
		}
	end
end