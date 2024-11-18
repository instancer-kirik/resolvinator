defmodule Resolvinator.Projects.Behaviors.Scheduling do
	@moduledoc """
	Defines the behavior for projects that require scheduling capabilities.
	This includes timeline management, milestone tracking, and deadline handling.
	"""

	@doc """
	Returns whether scheduling features are enabled for this project
	"""
	@callback scheduling_enabled?() :: boolean()

	@doc """
	Returns the scheduling settings for the project
	"""
	@callback scheduling_settings() :: map()

	@doc """
	Returns the timeline configuration
	"""
	@callback timeline_config() :: map()

	@doc """
	Validates scheduling-specific settings
	"""
	@callback validate_scheduling_settings(settings :: map()) :: :ok | {:error, String.t()}

	@optional_callbacks [
		scheduling_enabled?: 0,
		scheduling_settings: 0,
		timeline_config: 0,
		validate_scheduling_settings: 1
	]

	def default_scheduling_settings do
		%{
			timeline_visible: true,
			milestone_tracking: true,
			deadline_notifications: true,
			scheduling_mode: "flexible",
			dependencies_enabled: true,
			notification_preferences: %{
				milestone_updates: true,
				deadline_reminders: true,
				schedule_conflicts: true
			}
		}
	end
end